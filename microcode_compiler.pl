use v5.36;
use utf8;

my %ALU1_regs = (
    "A" => 0,
    "R" => 1,
    "T" => 2,
);

my %ALU2_regs = (
    "1" => 0,
    "-1" => 1,
    "S" => 2,
);

my %ALU_output_regs = (
    "A" => 0,
    "B" => 1,
    "T" => 2,
    "R" => 3,
);

my %ALU_op = (
    "+" => 0,
    "&" => 1,
    "^" => 2,
    ">>" => 3,
    "<<" => 4,
    "~" => 5,
);

my %bus_input_regs = (
    "0" => 0,
    "1" => 1,
    "A" => 2,
    "B" => 3,
    "dsp" => 4,
    "mem_in" => 5,
    "pc" => 6,
    "R" => 7,
    "rsp" => 8,
    "S" => 9,
    "T" => 10,
);

my %bus_output_regs = (
    "A" => 0,
    "A[31]" => 1,
    "B" => 2,
    "carry" => 3,
    "cmd" => 4,
    "eam" => 5,
    "mem_address" => 6,
    "mem_out" => 7,
    "pc" => 8,
    "R" => 9,
    "S" => 10,
    "T" => 11,
);

my %goto_regs = (
    "A" => 0,
    "R" => 1,
    "T" => 2,
);

my %opcodes = (
    "lit" => 0,
    "fetch_addr" => 1,
    "fetch" => 2,
    "fetch_plus" => 3,
    "fetch_b" => 4,
    "store_addr" => 5,
    "store" => 6,
    "store_plus" => 7,
    "store_b" => 8,
    "a_store" => 9,
    "b_store" => 10,
    "a_fetch" => 11,
    "add" => 12,
    "mul_step" => 13,
    "left_shift" => 14,
    "right_shift" => 15,
    "inv" => 16,
    "eam" => 17,
    "and" => 18,
    "xor" => 19,
    "drop" => 20,
    "dup" => 21,
    "over" => 22,
    "return" => 23,
    "call" => 24,
    "jump" => 25,
    "next" => 26,
    "if" => 27,
    "-if" => 28,
    "r>" => 29,
    ">r" => 30,
);

my @microcode_lines;
my %opcodes_address;
my %symbols;
my $mc = 0;

while (my $line = <>) {
    if ($line =~ /\#\+begin_src text/i ..
        $line =~ /\#\+end_src/i) {

        if ($line =~ /\#\+begin_src text/i) {
            if ($line =~ /:opcode\s+(?<opcode>\S+)/) {
                $opcodes_address{$+{opcode}} = $mc;
            }

            next
        }
        next if ($line =~ /\#\+end_src/i);
        next if ($line =~ /^\s+$/);

        if ($line =~ /(?<label>\S+):/) {
            $symbols{$+{label}} = $mc;

            next
        }

        $mc = $mc + 1;

        push @microcode_lines, $line;
    }
}

foreach my $mc (0 .. $#microcode_lines) {
    my $line = $microcode_lines[$mc];

    if ($line =~ /ALU/) {
        parse_alu($line, $mc);
    }

    elsif ($line =~ /<\-/) {
        parse_move($line, $mc);
    }

    elsif ($line =~ /\+=|\-=|mem_read|mem_write/) {
        parse_offset($line, $mc);
    }

    elsif ($line =~ /goto/) {
        parse_goto($line, $mc);
    }

    else {
        die "Не понял что за строчка такая интересная:\n$line";
    }
}

sub parse_alu ($line, $mc) {
    my $m_ALU1_mux_reg;
    my $m_ALU2_mux_reg = 0;
    my $m_ALU_output_mux_reg;
    my $m_ALU_op;

    if ($line =~ s/ALU\s+<\-\s+(?<reg>\S+);//) {
        $m_ALU1_mux_reg = $ALU1_regs{$+{reg}};
    }

    if ($line =~ s/ALU\s+<\-\s+(?<reg>\S+);//) {
        $m_ALU2_mux_reg = $ALU2_regs{$+{reg}};
    }

    if ($line =~ s/(?<op>\+|\&|\^|<<|>>|~)//) {
        $m_ALU_op = $ALU_op{$+{op}};
    }

    if ($line =~ s/(?<reg>\S+)\s+<\-\s+ALU//) {
        $m_ALU_output_mux_reg = $ALU_output_regs{$+{reg}};
    }

    print "rom[$mc] = {2'd$m_ALU1_mux_reg, 2'd$m_ALU2_mux_reg, 2'd$m_ALU_output_mux_reg, 3'd$m_ALU_op, 2'b00};\n";
}

sub parse_move ($line, $mc) {
    my $m_bus_input_mux_reg;
    my $m_bus_output_mux_reg;

    if ($line =~ s/(?<A>\S+)\s+<\-\s+(?<B>\S+)//) {
        $m_bus_input_mux_reg = $bus_input_regs{$+{B}};
        $m_bus_output_mux_reg = $bus_output_regs{$+{A}};
    }

    print "rom[$mc] = {4'd$m_bus_input_mux_reg, 4'd$m_bus_output_mux_reg, 2b01};\n";
}

sub parse_offset ($line, $mc) {
    my $m_pc_offset = 0;
    my $m_dsp_offset = 0;
    my $m_rsp_offset = 0;
    my $m_mem_read = 0;
    my $m_mem_write = 0;

    $m_pc_offset = 1 if ($line =~ s/pc\s+\+=\s+1//);
    $m_pc_offset = 2 if ($line =~ s/pc\s+\+=\s+4//);
    $m_dsp_offset = 1 if ($line =~ s/dsp\s+\+=\s+4//);
    $m_dsp_offset = 2 if ($line =~ s/dsp\s+\-=\s+4//);
    $m_rsp_offset = 1 if ($line =~ s/rsp\s+\+=\s+4//);
    $m_rsp_offset = 2 if ($line =~ s/rsp\s+\-=\s+4//);
    $m_mem_read = 1 if ($line =~ s/mem_read//);
    $m_mem_write = 1 if ($line =~ s/mem_write//);

    print "rom[$mc] = {3'd$m_pc_offset, 3'd$m_dsp_offset, 3'd$m_rsp_offset, 1'd$m_mem_read, 1'd$m_mem_write, 2'b10};\n";
}

sub parse_goto ($line, $mc) {
    my $m_goto_address = 0;
    my $m_goto_mux_reg = 0;
    my $m_goto_mask = 0xffffffff;
    my $m_goto_cmd = 0;

    $m_goto_cmd = 1 if ($line =~ s/goto\s+cmd//);

    if ($line =~ s/goto\s+(?<label>\S+)//) {
        $m_goto_address = $symbols{$+{label}};

        unless (defined $m_goto_address) {
            die "Неизвестная метка: \"$+{label}\"";
        }
    }

    if ($line =~ s/if\s+(?<reg>\w+)(:?\[(:<high>\d+)(:? : (?<low>\d+))?\])?\s+==\s+0//) {
        $m_goto_mux_reg = $goto_regs{$+{reg}};

        if (defined $+{high}) {
            $m_goto_mask = (1 << $+{high});

            if (defined $+{low}) {
                $m_goto_mask = ($m_goto_mask << 1) - (1 << $+{low});
            }
        }
    }

    print "rom[$mc] = {9'd$m_goto_address, 2'd$m_goto_mux_reg, 32'd$m_goto_mask, 1'd$m_goto_cmd, 2'b11};\n";
}

foreach my $opcode (keys %opcodes_address) {
    print "opcodes[$opcodes{$opcode}] = 9'd$opcodes_address{$opcode};\n"
}
