`timescale 1ns / 1ps

module tb_atm_top;

reg clk, rst;
reg card_inserted;
reg [3:0] keypad_digit;
reg digit_valid;
reg [15:0] stored_pin;
reg [1:0] tx_sel;
reg amount_entered;
reg [7:0] amount_reg;

wire [7:0] account_balance;
wire eject_card;
wire blocked;
wire authenticated;
wire dispense_cash;
wire accept_cash;
wire [2:0] screen_msg;
wire tx_success;

atm_top uut (
    .clk(clk),
    .rst(rst),
    .card_inserted(card_inserted),
    .keypad_digit(keypad_digit),
    .digit_valid(digit_valid),
    .stored_pin(stored_pin),
    .tx_sel(tx_sel),
    .amount_entered(amount_entered),
    .amount_reg(amount_reg),
    .account_balance(account_balance),
    .eject_card(eject_card),
    .blocked(blocked),
    .authenticated(authenticated),
    .dispense_cash(dispense_cash),
    .accept_cash(accept_cash),
    .screen_msg(screen_msg),
    .tx_success(tx_success)
);

always #5 clk = ~clk;

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

task insert_card_and_enter_pin;
    begin
        card_inserted = 1; #10; card_inserted = 0; #10;
        enter_digit(4'd1);
        enter_digit(4'd2);
        enter_digit(4'd3);
        enter_digit(4'd4);
        #20;
    end
endtask

initial begin
    clk            = 0;
    rst            = 1;
    card_inserted  = 0;
    keypad_digit   = 0;
    digit_valid    = 0;
    stored_pin     = 16'h1234;
    tx_sel         = 2'b00;
    amount_entered = 0;
    amount_reg     = 8'd0;

    #20; rst = 0; #10;

    card_inserted = 1; #10; card_inserted = 0; #10;
    enter_digit(4'd9); enter_digit(4'd9);
    enter_digit(4'd9); enter_digit(4'd9);
    #30;
    enter_digit(4'd8); enter_digit(4'd8);
    enter_digit(4'd8); enter_digit(4'd8);
    #30;
    enter_digit(4'd7); enter_digit(4'd7);
    enter_digit(4'd7); enter_digit(4'd7);
    #40;
    $display("Test 1 done — Card blocked | blocked=%b (expect 1)", blocked);

    rst = 1; #20; rst = 0; #20;

    insert_card_and_enter_pin;
    tx_sel = 2'b01; #10;
    amount_reg = 8'd30;
    amount_entered = 1; #10; amount_entered = 0;
    #80;
    $display("Test 2 done — Withdraw 30 | balance should be 70 | tx_success=%b", tx_success);

    insert_card_and_enter_pin;
    tx_sel = 2'b10; #10;
    amount_reg = 8'd50;
    amount_entered = 1; #10; amount_entered = 0;
    #80;
    $display("Test 3 done — Deposit 50 | balance should be 120 | tx_success=%b", tx_success);

    insert_card_and_enter_pin;
    tx_sel = 2'b00; #80;
    $display("Test 4 done — Balance enquiry | balance=%d | tx_success=%b", account_balance, tx_success);

    insert_card_and_enter_pin;
    tx_sel = 2'b01; #10;
    amount_reg = 8'd200;
    amount_entered = 1; #10; amount_entered = 0;
    #80;
    $display("Test 5 done — Withdraw 200 insufficient | tx_success=%b (expect 0)", tx_success);

    #20;
    $display("All tests complete!");
    $finish;
end

initial begin
    $dumpfile("atm_top_sim.vcd");
    $dumpvars(0, tb_atm_top);
end

endmodule