// FXMADD UNIT

module copro_fxmadd
import cvxif_instr_pkg::*;
#(
    parameter int unsigned NrRgprPorts = 3,
    parameter int unsigned XLEN = 32,
    parameter type hartid_t = logic,
    parameter type id_t = logic,
    parameter type registers_t = logic

)(
    input  logic                  clk_i,
    input  logic                  rst_ni,
    input  registers_t            registers_i,
    input  opcode_t               opcode_i,
    input  logic            [2:0] funct3,
    input  logic            [1:0] funct2,
    input  hartid_t               hartid_i,
    input  id_t                   id_i,
    input  logic       [     4:0] rd_i,
    output logic       [XLEN-1:0] result_o,
    output hartid_t               hartid_o,
    output id_t                   id_o,
    output logic       [     4:0] rd_o,
    output logic                  valid_o,
    output logic                  we_o
);

/******** FXMADD *******/
logic[XLEN-1:0] shift_in, res_mul_shifted;
// Shift scale
logic[4:0] shift_scale;
logic[2:0] low_bits_selected_scale;
logic[1:0] high_bit_selected_scale;

/********  LSRF  *******/
logic[38:0] current_state;
logic[38:0] next_state;
lfsr_mode_t mode;

/******** CVXIF ********/
logic[XLEN-1:0] result_n, result_q;
hartid_t hartid_n, hartid_q;
id_t id_n, id_q;
logic valid_n, valid_q;
logic [4:0] rd_n, rd_q;
logic we_n, we_q;

assign low_bits_selected_scale = funct3;
assign high_bit_selected_scale = funct2;
assign result_o = result_q;
assign hartid_o = hartid_q;
assign id_o = id_q;
assign valid_o = valid_q;
assign rd_o = rd_q;
assign we_o = we_q;
assign shift_scale = {high_bit_selected_scale, low_bits_selected_scale};

always_comb begin
    mode = NONE;
    case(opcode_i)
        cvxif_instr_pkg::NOP: begin
            result_n = '0;
            hartid_n = hartid_i;
            id_n = id_i;
            valid_n = 1'b1;
            rd_n = '0;
            we_n = '0;
        end

        cvxif_instr_pkg::FXMADD: begin
            shift_in = $signed(registers_i[0]) * $signed(registers_i[1]);
            res_mul_shifted = $signed(shift_in) >>> shift_scale;
            result_n = $signed(res_mul_shifted) + $signed(registers_i[2]); 
            
            hartid_n = hartid_i;
            id_n = id_i;
            valid_n = 1'b1;
            rd_n = rd_i;
            we_n = 1'b1;
        end

        cvxif_instr_pkg::FXSEED: begin
            mode = LFSR_SEED;

            result_n = '0;
            hartid_n = hartid_i;
            id_n = id_i;
            valid_n = 1'b1;
            rd_n = '0;
            we_n = '0;
        end

        cvxif_instr_pkg::FXGEN: begin
            mode = LFSR_GEN;
            shift_in = {1'b0, current_state[30:0]};
            result_n = $signed(shift_in) >>> shift_scale;
            hartid_n = hartid_i;
            id_n = id_i;
            valid_n = 1'b1;
            rd_n = rd_i;
            we_n = 1'b1;
        end

        default: begin
            result_n = '0;
            hartid_n = '0;
            id_n     = '0;
            valid_n  = '0;
            rd_n     = '0;
            we_n     = '0;
        end

    endcase
end



always_ff @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
        result_q <= '0;
        hartid_q <= '0;
        id_q     <= '0;
        valid_q  <= '0;
        rd_q     <= '0;
        we_q     <= '0;
    end else begin
        result_q <= result_n;
        hartid_q <= hartid_n;
        id_q     <= id_n;
        valid_q  <= valid_n;
        rd_q     <= rd_n;
        we_q     <= we_n;

        if(mode == LFSR_SEED) begin
            current_state <= {7'b1010101, registers_i[0]};
        end else if (mode == LFSR_GEN) begin
            current_state <= next_state;
        end
    end
end

// Generated code, 32 XOR
always_comb begin
    next_state[38] = current_state[35] ^ current_state[31];
    next_state[37] = current_state[34] ^ current_state[30];
    next_state[36] = current_state[33] ^ current_state[29];
    next_state[35] = current_state[32] ^ current_state[28];
    next_state[34] = current_state[31] ^ current_state[27];
    next_state[33] = current_state[30] ^ current_state[26];
    next_state[32] = current_state[29] ^ current_state[25];
    next_state[31] = current_state[28] ^ current_state[24];
    next_state[30] = current_state[27] ^ current_state[23];
    next_state[29] = current_state[26] ^ current_state[22];
    next_state[28] = current_state[25] ^ current_state[21];
    next_state[27] = current_state[24] ^ current_state[20];
    next_state[26] = current_state[23] ^ current_state[19];
    next_state[25] = current_state[22] ^ current_state[18];
    next_state[24] = current_state[21] ^ current_state[17];
    next_state[23] = current_state[20] ^ current_state[16];
    next_state[22] = current_state[19] ^ current_state[15];
    next_state[21] = current_state[18] ^ current_state[14];
    next_state[20] = current_state[17] ^ current_state[13];
    next_state[19] = current_state[16] ^ current_state[12];
    next_state[18] = current_state[15] ^ current_state[11];
    next_state[17] = current_state[14] ^ current_state[10];
    next_state[16] = current_state[13] ^ current_state[9];
    next_state[15] = current_state[12] ^ current_state[8];
    next_state[14] = current_state[11] ^ current_state[7];
    next_state[13] = current_state[10] ^ current_state[6];
    next_state[12] = current_state[9] ^ current_state[5];
    next_state[11] = current_state[8] ^ current_state[4];
    next_state[10] = current_state[7] ^ current_state[3];
    next_state[9] = current_state[6] ^ current_state[2];
    next_state[8] = current_state[5] ^ current_state[1];
    next_state[7] = current_state[4] ^ current_state[0];
    next_state[6] = current_state[38];
    next_state[5] = current_state[37];
    next_state[4] = current_state[36];
    next_state[3] = current_state[35];
    next_state[2] = current_state[34];
    next_state[1] = current_state[33];
    next_state[0] = current_state[32];
end

endmodule
