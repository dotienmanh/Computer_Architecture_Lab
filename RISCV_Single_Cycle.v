module RISCV_Single_Cycle(clk,rst_n);

input clk;
input rst_n;

wire [31:0] PC_in_top,PC_out_top,Instruction_out_top,PC_Plus4_top;
wire [31:0] DataA_top, DataB_top, DataD_top, ALU_out_top, Imm_top, Mux_ALU_DataA_top, Mux_ALU_DataB_top, DataR_top;
wire [3:0] ALUSel_top;
wire PCSel_top, RegWEn_top, MemRW_top, Asel_top, Bsel_top, BrUn_top, BrEq_top, BrLt_top;
wire [1:0] WBSel_top;
wire [2:0] ImmSel_top;

Control_Unit Control_logic(
    .Inst  (Instruction_out_top),
    .BrEq  (BrEq_top),
    .BrLt  (BrLt_top),
    .PCSel (PCSel_top),
    .ImmSel(ImmSel_top),
    .RegWEn(RegWEn_top),
    .BrUn  (BrUn_top),
    .Bsel  (Bsel_top),
    .Asel  (Asel_top),
    .ALUSel(ALUSel_top),
    .MemRW (MemRW_top),
    .WBSel (WBSel_top)
);

Mux Mux_PC(
    .Sel    (PCSel_top),
    .In_1   (ALU_out_top),
    .In_0   (PC_Plus4_top),
    .Mux_out(PC_in_top)
);

Program_Counter PC(
    .clk   (clk),
    .rst_n (rst_n),
    .PC_in (PC_in_top),
    .PC_out(PC_out_top)
);

Adder Add(
    .a  (PC_out_top),
    .b  (32'h00000004),
    .sum(PC_Plus4_top)
);

Instruction_Memory IMEM(
    .clk  (clk),
    .rst_n(rst_n),
    .addr (PC_out_top), 
    .inst (Instruction_out_top)
);

Immediate_Generator Imm_Gen(
    .Inst  (Instruction_out_top[31:20]),
    .ImmSel(ImmSel_top),
    .Imm   (Imm_top)
);

Registers_File Reg (   
    .clk    (clk),
    .rst_n  (rst_n),
    .AddrA  (Instruction_out_top[19:15]),
    .AddrB  (Instruction_out_top[24:20]),
    .AddrD  (Instruction_out_top[11:7]),
    .DataD  (DataD_top),
    .RegWEn (RegWEn_top),
    .DataA  (DataA_top),
    .DataB  (DataB_top)
);

Branch_Comp Branch_Comp(
    .dataA (DataA_top),
    .dataB (DataB_top),
    .BrUn  (BrUn_top),
    .BrEq  (BrEq_top),
    .BrLt  (BrLt_top)
);

Mux Mux_ALU_DataA(
    .Sel    (Asel_top),
    .In_1   (PC_Plus4_top),
    .In_0   (DataA_top),
    .Mux_out(Mux_ALU_DataA_top)
);

Mux Mux_ALU_DataB(
    .Sel(Bsel_top),
    .In_1(Imm_top),
    .In_0(DataB_top),
    .Mux_out(Mux_ALU_DataB_top)
);

ALU ALU_mod (   
    .A(Mux_ALU_DataA_top),
    .B(Mux_ALU_DataB_top),
    .ALUSel(ALUSel_top),
    .ALU_out(ALU_out_top)
);

Data_Memory Dmem (   
    .clk(clk),
    .rst_n(rst_n),
    .MemRW(MemRW_top),
    .addr(ALU_out_top),
    .DataW(DataB_top),
    .DataR(DataR_top)
);

Mux3_1 Mux3_1_WB(
    .Sel(WBSel_top),
    .In_2(PC_Plus4_top),
    .In_1(ALU_out_top),
    .In_0(DataR_top),
    .Mux3_1_out(DataD_top)
);

endmodule