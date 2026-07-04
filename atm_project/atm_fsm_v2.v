module atm_fsm(
    input clk,
    input rst,
    input card_inserted,
    input [3:0] keypad_digit,    // one digit at a time (0-9)
    input digit_valid,           // goes high when a digit is pressed
    input [15:0] stored_pin,     // correct PIN stored in memory
    input tx_done,
    output reg eject_card,
    output reg blocked,
    output reg tx_start,
    output reg authenticated
);

// ── State encoding ──────────────────────────────
parameter IDLE          = 4'd0;
parameter CARD_INSERTED = 4'd1;
parameter WAIT_PIN      = 4'd2;
parameter VERIFY_PIN    = 4'd3;
parameter PIN_ERROR     = 4'd4;
parameter CARD_BLOCKED  = 4'd5;
parameter AUTHENTICATED = 4'd6;
parameter PROCESSING    = 4'd7;
parameter DONE          = 4'd8;

// ── Registers ───────────────────────────────────
reg [3:0]  state, next_state;
reg [1:0]  try_count;
reg [15:0] entered_pin;     // built up digit by digit
reg [1:0]  digit_count;     // counts how many digits entered (0 to 4)
reg        pin_entered;     // goes high when all 4 digits are in

// ── State register block ────────────────────────
always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

// ── Shift register block ────────────────────────
// Builds the PIN digit by digit using shift register
always @(posedge clk or posedge rst) begin
    if (rst) begin
        entered_pin <= 16'd0;
        digit_count <= 2'd0;
        pin_entered <= 1'b0;
    end
    else if (state == IDLE || state == CARD_INSERTED) begin
        // Reset PIN registers when starting fresh
        entered_pin <= 16'd0;
        digit_count <= 2'd0;
        pin_entered <= 1'b0;
    end
    else if (state == WAIT_PIN && digit_valid) begin
        // Shift in new digit from keypad
        // Each new digit goes into the rightmost 4 bits
        entered_pin <= {entered_pin[11:0], keypad_digit};
        digit_count <= digit_count + 1;

        // After 4 digits entered, signal PIN is ready
        if (digit_count == 2'd3)
            pin_entered <= 1'b1;
        else
            pin_entered <= 1'b0;
    end
    else begin
        pin_entered <= 1'b0;
    end
end

// ── Next state logic ────────────────────────────
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
            next_state = CARD_BLOCKED;
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
always @(posedge clk or posedge rst) begin
    if (rst)
        try_count <= 0;
    else if (state == IDLE)
        try_count <= 0;
    else if (state == PIN_ERROR)
        try_count <= try_count + 1;
end

// ── Output block ────────────────────────────────
always @(*) begin
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