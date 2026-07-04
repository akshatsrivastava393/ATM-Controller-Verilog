`timescale 1ns / 1ps

module tb_atm_v2;

// ── Inputs
reg clk;
reg rst;
reg card_inserted;
reg [3:0] keypad_digit;
reg digit_valid;
reg [15:0] stored_pin;
reg tx_done;

// ── Outputs
wire eject_card;
wire blocked;
wire tx_start;
wire authenticated;

// ── Connect testbench to new FSM module
atm_fsm uut (
    .clk(clk),
    .rst(rst),
    .card_inserted(card_inserted),
    .keypad_digit(keypad_digit),
    .digit_valid(digit_valid),
    .stored_pin(stored_pin),
    .tx_done(tx_done),
    .eject_card(eject_card),
    .blocked(blocked),
    .tx_start(tx_start),
    .authenticated(authenticated)
);

// ── Clock generator
always #5 clk = ~clk;

// ── Task for entering one digit
// This makes it easy to send digits one at a time
task enter_digit;
    input [3:0] digit;
    begin
        @(posedge clk);
        keypad_digit = digit;
        digit_valid  = 1;
        @(posedge clk);
        digit_valid  = 0;
        keypad_digit = 0;
        #10;
    end
endtask

// ── Test sequence
initial begin
    // Initialise
    clk          = 0;
    rst          = 1;
    card_inserted = 0;
    keypad_digit  = 4'd0;
    digit_valid   = 0;
    stored_pin    = 16'h1234; // correct PIN is 1-2-3-4
    tx_done       = 0;

    // Hold reset
    #10;
    rst = 0;
    #10;

    // ── Test 1: Insert card
    card_inserted = 1;
    #10;
    card_inserted = 0;
    #10;

    // ── Test 2: Enter WRONG PIN (5-6-7-8) — attempt 1
    enter_digit(4'd5);
    enter_digit(4'd6);
    enter_digit(4'd7);
    enter_digit(4'd8);
    #20;

    // ── Test 3: Enter WRONG PIN (9-9-9-9) — attempt 2
    enter_digit(4'd9);
    enter_digit(4'd9);
    enter_digit(4'd9);
    enter_digit(4'd9);
    #20;

    // ── Test 4: Enter WRONG PIN (0-0-0-0) — attempt 3
    // This should trigger CARD_BLOCKED
    enter_digit(4'd0);
    enter_digit(4'd0);
    enter_digit(4'd0);
    enter_digit(4'd0);
    #30;

    // ── Reset after block
    rst = 1;
    #10;
    rst = 0;
    #10;

    // ── Test 5: Insert card again
    card_inserted = 1;
    #10;
    card_inserted = 0;
    #10;

    // ── Test 6: Enter CORRECT PIN (1-2-3-4)
    enter_digit(4'd1);
    enter_digit(4'd2);
    enter_digit(4'd3);
    enter_digit(4'd4);
    #20;

    // ── Test 7: Complete transaction
    tx_done = 1;
    #10;
    tx_done = 0;
    #30;

    $display("Simulation complete!");
    $finish;
end

// ── Waveform dump
initial begin
    $dumpfile("atm_sim_v2.vcd");
    $dumpvars(0, tb_atm_v2);
end

endmodule