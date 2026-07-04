module atm_fsm(
    input clk,
    input rst,
    input card_inserted,
    input pin_entered,
    input [15:0] entered_pin,
    input [15:0] stored_pin,
    input tx_done,
    output reg eject_card,
    output reg blocked,
    output reg tx_start,
    output reg authenticated
);

// ── State encoding ──────────────────────────────
parameter IDLE         = 4'd0;
parameter CARD_INSERTED = 4'd1;
parameter WAIT_PIN     = 4'd2;
parameter VERIFY_PIN   = 4'd3;
parameter PIN_ERROR    = 4'd4;
parameter CARD_BLOCKED = 4'd5;
parameter AUTHENTICATED = 4'd6;
parameter PROCESSING   = 4'd7;
parameter DONE         = 4'd8;

// ── State and counter registers ─────────────────
reg [3:0] state, next_state;
reg [1:0] try_count;

// ── State register block ────────────────────────
// This block updates the state on every clock tick
always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

// ── Next state logic ────────────────────────────
// This block decides which state comes next
always @(*) begin
    case (state)

        IDLE: begin
            if (card_inserted)
                next_state = CARD_INSERTED;
            else
                next_state = IDLE;
        end

        CARD_INSERTED: begin
            next_state = WAIT_PIN;
        end

        WAIT_PIN: begin
            if (pin_entered)
                next_state = VERIFY_PIN;
            else
                next_state = WAIT_PIN;
        end

        VERIFY_PIN: begin
            if (entered_pin == stored_pin)
                next_state = AUTHENTICATED;
            else
                next_state = PIN_ERROR;
        end

        PIN_ERROR: begin
            if (try_count >= 2)
                next_state = CARD_BLOCKED;
            else
                next_state = WAIT_PIN;
        end

        CARD_BLOCKED: begin
            next_state = CARD_BLOCKED; // stays here until reset
        end

        AUTHENTICATED: begin
            next_state = PROCESSING;
        end

        PROCESSING: begin
            if (tx_done)
                next_state = DONE;
            else
                next_state = PROCESSING;
        end

        DONE: begin
            next_state = IDLE;
        end

        default: next_state = IDLE;
    endcase
end

// ── Try counter block ───────────────────────────
// Counts wrong PIN attempts
always @(posedge clk or posedge rst) begin
    if (rst)
        try_count <= 0;
    else if (state == IDLE)
        try_count <= 0;
    else if (state == PIN_ERROR)
        try_count <= try_count + 1;
end

// ── Output block ────────────────────────────────
// Sets outputs based on current state (Moore machine)
always @(*) begin
    // Default all outputs to 0
    eject_card    = 0;
    blocked       = 0;
    tx_start      = 0;
    authenticated = 0;

    case (state)
        IDLE:          eject_card    = 0;
        CARD_BLOCKED:  blocked       = 1;
        AUTHENTICATED: authenticated = 1;
        PROCESSING:    tx_start      = 1;
        DONE:          eject_card    = 1;
        default:       eject_card    = 0;
    endcase
end

endmodule