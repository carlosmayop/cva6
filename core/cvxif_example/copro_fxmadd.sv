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
    // Shift scale
    //input logic[2:0] low_bits_selected_scale,
    //input logic[1:0] high_bit_selected_scale,
);

logic[XLEN-1:0] res_mul, res_mul_shifted;
logic[4:0] shift_value;
logic[2:0] low_bits_selected_scale;
logic[1:0] high_bit_selected_scale;

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

always_comb begin

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
            shift_value = {high_bit_selected_scale, low_bits_selected_scale};
            res_mul = $signed(registers_i[0]) * $signed(registers_i[1]);
            res_mul_shifted = $signed(res_mul) >>> shift_value;
            result_n = $signed(res_mul_shifted) + $signed(registers_i[2]); 
            
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
    end
end

endmodule
