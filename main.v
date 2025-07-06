module Encryptor(
    input  [7:0] plain,
    input  [7:0] key,
    output [7:0] cipher
);
    wire [7:0] xor_result;
    assign xor_result = plain ^ key;
    assign cipher = {xor_result[6:0], xor_result[7]};  // Rotate left by 1
endmodule
module Decryptor(
    input  [7:0] cipher,
    input  [7:0] key,
    output [7:0] plain
);
    wire [7:0] rotated;
    assign rotated = {cipher[0], cipher[7:1]};  // Rotate right by 1
    assign plain = rotated ^ key;
endmodule
module PasswordStorage(
    input             clk,
    input             write_en,
    input      [3:0]  write_addr,
    input      [7:0]  write_data,
    input      [3:0]  read_addr,
    output reg [7:0]  read_data
);
    reg [7:0] memory [0:9];
    integer i;
    initial begin
        for(i = 0; i < 10; i = i + 1)
            memory[i] = 8'd0;
    end
    always @(posedge clk) begin
        if (write_en) begin
            memory[write_addr] <= write_data;
        end
    end
    always @(*) begin
        read_data = memory[read_addr];
    end
endmodule
module MasterValidator #(
    parameter [7:0] MASTER_PASS = 8'hA5
)(
    input  [7:0] entered_pass,
    output       unlocked
);
    assign unlocked = (entered_pass == MASTER_PASS);
endmodule
module TopModule(
    input        clk,
    input  [7:0] plain_in,
    input  [7:0] master_key,
    input  [3:0] addr_index,
    input        write_enable,
    input  [7:0] entered_master,
    output       unlocked,
    output [7:0] dec_out
);
    wire [7:0] enc_out;
    wire [7:0] stored_cipher;
    Encryptor encryptor_inst (
        .plain(plain_in),
        .key(master_key),
        .cipher(enc_out)
    );
    Decryptor decryptor_inst (
        .cipher(stored_cipher),
        .key(master_key),
        .plain(dec_out)
    );
    PasswordStorage storage_inst (
        .clk(clk),
        .write_en(write_enable),
        .write_addr(addr_index),
        .write_data(enc_out),
        .read_addr(addr_index),
        .read_data(stored_cipher)
    );
    MasterValidator #(.MASTER_PASS(8'hA5)) validator_inst (
        .entered_pass(entered_master),
        .unlocked(unlocked)
    );
endmodule
module testbench;
    reg clk;
    // Signals
    reg  [7:0] plain_in;
    wire [7:0] enc_out;
    reg  [7:0] master_key;
    reg  [7:0] entered_master;
    wire       unlocked;
    reg  [3:0] addr_index;
    reg        write_enable;
    wire [7:0] stored_cipher;
    wire [7:0] dec_out;
    // Instantiate Modules
    Encryptor encryptor_inst (
        .plain(plain_in),
        .key(master_key),
        .cipher(enc_out)
    );
    Decryptor decryptor_inst (
        .cipher(stored_cipher),
        .key(master_key),
        .plain(dec_out)
    );
    PasswordStorage storage_inst (
        .clk(clk),
        .write_en(write_enable),
        .write_addr(addr_index),
        .write_data(enc_out),
        .read_addr(addr_index),
        .read_data(stored_cipher)
    );
    MasterValidator #(.MASTER_PASS(8'hA5)) validator_inst (
        .entered_pass(entered_master),
        .unlocked(unlocked)
    );
    // User-entered password array
    reg [7:0] passwords [0:9];  // 10 passwords of 8-bit each
    integer i;
    initial begin
        // Initialize simulation signals
        clk = 0;
        master_key = 8'hA5;
        write_enable = 0;
        addr_index = 0;
        entered_master = 8'h00;
        // Manually input (simulate user-entered) plaintext passwords
        passwords[0] = 8'h12;
        passwords[1] = 8'h3A;
        passwords[2] = 8'h5F;
        passwords[3] = 8'h9B;
        passwords[4] = 8'h04;
        passwords[5] = 8'hE7;
        passwords[6] = 8'hAC;
        passwords[7] = 8'hD1;
        passwords[8] = 8'h23;
        passwords[9] = 8'h7C;
        $display("User entered 10 plaintext passwords.");
        $display("Beginning encryption and secure storage...\n");
        // Encrypt and store the passwords
        for (i = 0; i < 10; i = i + 1) begin
            plain_in = passwords[i];
            #1;
            addr_index = i;
            write_enable = 1;
            @(posedge clk);
            write_enable = 0;
            @(negedge clk);
            $display("Encrypted and stored password %0d: 0x%02h", i, enc_out);
        end
        $display("\nAttempting access with incorrect master password...");
        entered_master = 8'hFF;  // incorrect
        #1;
        if (unlocked)
            $display("ERROR: Dictionary unlocked with incorrect password!\n");
        else
            $display("Access DENIED. Dictionary remains locked.\n");
        $display("Attempting access with correct master password...");
        entered_master = master_key;
        #1;
        if (unlocked) begin
            $display("Access GRANTED. Decrypting stored passwords...\n");
            for (i = 0; i < 10; i = i + 1) begin
                addr_index = i;
                #1;
                $display("Password %0d decrypted: 0x%02h (expected: 0x%02h)", i, dec_out, passwords[i]);
            end
        end else begin
            $display("ERROR: Correct master password was rejected.");
        end
        $display("\nTestbench complete.");
        $finish;
    end
    // Clock: 10ns period
    always #5 clk = ~clk;
endmodule
