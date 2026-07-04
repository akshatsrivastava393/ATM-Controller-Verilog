`timescale 1ns/1ps

module tb_tx;

reg clk;
reg rst;
reg tx_start;
reg [1:0] tx_sel;
reg amount_entered;
reg [7:0] amount_reg;

wire [7:0] account_balance;
wire tx_done;
wire tx_success;
wire dispense_cash;
wire accept_cash;
wire [2:0] screen_msg;

tx_fsm uut(
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_sel(tx_sel),
    .amount_entered(amount_entered),
    .amount_reg(amount_reg),
    .account_balance(account_balance),
    .tx_done(tx_done),
    .tx_success(tx_success),
    .dispense_cash(dispense_cash),
    .accept_cash(accept_cash),
    .screen_msg(screen_msg)
);

always #5 clk=~clk;

initial begin

    clk=0;
    rst=1;
    tx_start=0;
    tx_sel=0;
    amount_entered=0;
    amount_reg=0;

    #10;
    rst=0;
    #10;

    tx_sel=2'b00;
    #10;
    tx_start=1;
    #10;
    tx_start=0;
    #60;

    tx_sel=2'b01;
    #10;
    tx_start=1;
    #10;
    tx_start=0;
    #10;
    amount_reg=8'd50;
    amount_entered=1;
    #10;
    amount_entered=0;
    #60;

    tx_sel=2'b01;
    #10;
    tx_start=1;
    #10;
    tx_start=0;
    #10;
    amount_reg=8'd150;
    amount_entered=1;
    #10;
    amount_entered=0;
    #60;

    tx_sel=2'b10;
    #10;
    tx_start=1;
    #10;
    tx_start=0;
    #10;
    amount_reg=8'd75;
    amount_entered=1;
    #10;
    amount_entered=0;
    #60;

    $finish;

end

initial begin
    $dumpfile("tx_sim.vcd");
    $dumpvars(0,tb_tx);
end

endmodule