`timescale 1ns / 1ps

module tb_atm;

// ── Inputs (these are reg because we control them)
reg clk;
reg rst;
reg card_inserted;
reg pin_entered;
reg [15:0] entered_pin;
reg [15:0] stored_pin;
reg tx_done;

// ── Outputs (these are wire because FSM drives them)
wire eject_card;
wire blocked;
wire tx_start;
wire authenticated;

// ── Connect testbench to your FSM module
atm_fsm uut (
    .clk(clk),
    .rst(rst),
    .card_inserted(card_inserted),
    .pin_entered(pin_entered),
    .entered_pin(entered_pin),
    .stored_pin(stored_pin),
    .tx_done(tx_done),
    .eject_card(eject_card),
    .blocked(blocked),
    .tx_start(tx_start),
    .authenticated(authenticated)
);

// ── Clock generator (toggles every 5ns = 100MHz)
always #5 clk = ~clk;

// ── Test sequence
initial begin
    // Initialise everything
    clk           = 0;
    rst           = 1;
    card_inserted = 0;
    pin_entered   = 0;
    entered_pin   = 16'd0;
    stored_pin    = 16'd1234;
    tx_done       = 0;

    // Hold reset for 2 clock cycles
    #10;
    rst = 0;

    // ── Test 1: Wrong PIN attempt 1
    #10 card_inserted = 1;
    #10 card_inserted = 0;
    #10 pin_entered   = 1;
        entered_pin   = 16'd9999; // wrong PIN
    #10 pin_entered   = 0;

    // ── Test 2: Wrong PIN attempt 2
    #20 pin_entered   = 1;
        entered_pin   = 16'd1111; // wrong PIN
    #10 pin_entered   = 0;

    // ── Test 3: Wrong PIN attempt 3 → triggers CARD_BLOCKED
    #20 pin_entered   = 1;
        entered_pin   = 16'd5555; // wrong PIN
    #10 pin_entered   = 0;

    // Wait and observe CARD_BLOCKED state
    #30;

    // ── Reset and try correct PIN
    rst = 1;
    #10 rst = 0;

    #10 card_inserted = 1;
    #10 card_inserted = 0;
    #10 pin_entered   = 1;
        entered_pin   = 16'd1234; // correct PIN
    #10 pin_entered   = 0;

    // ── Simulate transaction completing
    #20 tx_done = 1;
    #10 tx_done = 0;

    // Wait to observe DONE state
    #30;

    $display("Simulation complete!");
    $finish;
end

// ── Waveform dump (generates the .vcd file for GTKWave)
initial begin
    $dumpfile("atm_sim.vcd");
    $dumpvars(0, tb_atm);
end

endmodule