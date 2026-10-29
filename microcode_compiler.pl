use strict;
use warnings;
use utf8;

my %ALU1_regs = {
    A => 0,
    R => 1,
    T => 2,
};

my %ALU2_regs = {
    "1" => 0,
    "-1" => -1,
    "S" => 2,
};

my %ALU_output_regs = {
    "A" => 0,
    "B" => 1,
    "T" => 2,
};

my %bus_input_regs = {
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
};

my %bus_output_regs = {
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
};

my @microcode_lines;
my %opcodes;
my %symbols;
my $mc = 0;

while (my $line = <>) {
    if ($line =~ /\#\+begin_src text/i ..
        $line =~ /\#\+end_src/i) {

        if ($line =~ /\#\+begin_src text/i) {
            if ($line =~ /:opcode\s+(?<opcode>\w+)/) {
                $opcodes{$+{opcode}} = $mc;
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

        print $line;
    }
}

# print $mc . "\n";

# foreach my $symbol (keys %symbols){
#     print $symbol . ": " . $symbols{$symbol} . "\n";
# }

# foreach my $opcode (keys %opcodes){
#     print $opcode . ": " . $opcodes{$opcode} . "\n";
# }
