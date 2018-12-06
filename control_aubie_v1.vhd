
use work.bv_arithmetic.all; 
use work.dlx_types.all; 

entity aubie_controller is
	generic(propDelay : time := 15 ns);
	port(ir_control: in dlx_word;
	     alu_out: in dlx_word; 
	     alu_error: in error_code; 
	     clock: in bit; 
	     regfilein_mux: out threeway_muxcode; 
	     memaddr_mux: out threeway_muxcode; 
	     addr_mux: out bit; 
	     pc_mux: out bit; 
	     alu_func: out alu_operation_code; 
	     regfile_index: out register_index;
	     regfile_readnotwrite: out bit; 
	     regfile_clk: out bit;   
	     mem_clk: out bit;
	     mem_readnotwrite: out bit;  
	     ir_clk: out bit; 
	     imm_clk: out bit; 
	     addr_clk: out bit;  
             pc_clk: out bit; 
	     op1_clk: out bit; 
	     op2_clk: out bit; 
	     result_clk: out bit
	     ); 
end aubie_controller; 

architecture behavior of aubie_controller is
begin
	behav: process(clock) is 
		type state_type is range 1 to 20; 
		variable state: state_type := 1; 
		variable opcode: byte; 
		variable destination,operand1,operand2 : register_index; 

	begin
		if clock'event and clock = '1' then
		   opcode := ir_control(31 downto 24);
		   destination := ir_control(23 downto 19);
		   operand1 := ir_control(18 downto 14);
		   operand2 := ir_control(13 downto 9); 
		   case state is
			when 1 => -- fetch the instruction, for all types
				-- your code goes here

				-- Handle clocks and multiplexers and etc.:
				-- fetching (reading) from memory, not register file
				mem_readnotwrite <= '1' after propDelay; -- reading from memory, not writing

				memaddr_mux <= "00" after propDelay; -- could be the wrong mux code -> need to test
				addr_mux <= '1' after propDelay; -- mux code for mem_out path
				
				imm_clk <= '0' after propDelay; -- immediate register not used here
				addr_clk <= '0' after propDelay; -- addr register not used here
				pc_clk <= '0' after propDelay; -- want to use current pc value
				op1_clk <= '0' after propDelay; -- no operation in this state
				op2_clk <= '0' after propDelay; -- no operation in this state				
				result_clk <= '0' after propDelay; -- no operation in this state
				regfile_clk <= '0' after propDelay; -- register file not used here
				mem_clk <= '1' after propDelay; -- 1 -> so it can be read
				ir_clk <= '1' after propDelay; -- needs to be 1 so it can have mem[pc]
				

				state := 2; 
			when 2 =>  
				
				-- figure out which instruction
			 	if opcode(7 downto 4) = "0000" then -- ALU op
					state := 3; 
				elsif opcode = X"20" then  -- STO 
					-- my code
					state := 9;
				elsif opcode = X"30" or opcode = X"31" then -- LD or LDI
					state := 7;
				elsif opcode = X"22" then -- STOR
					-- my code
					state := 14;
				elsif opcode = X"32" then -- LDR
					-- my code
					state := 12;
				elsif opcode = X"40" or opcode = X"41" then -- JMP or JZ
					-- my code
					state := 16;
				elsif opcode = X"10" then -- NOOP
					-- my code
					state := 19;
				else -- error
				end if; 
			when 3 => 
				-- ALU op:  load op1 register from the regfile
				-- your code here
				-- operand1 variable is an index value*****

				regfile_index <= operand1 after propDelay; 

				regfile_readnotwrite <= '1' after propDelay; -- reading from reg file

				-- clocks: only op1_clk and regfile_clk are 1 since they're used, everything else is 0
				regfile_clk <= '1' after propDelay;
				op1_clk <= '1' after propDelay;
				mem_clk <= '0' after propDelay; -- memory not used here
				ir_clk <= '0' after propDelay; -- instr register not used here
				imm_clk <= '0' after propDelay; -- imm reg not used here
				addr_clk <= '0' after propDelay; -- addr reg not used here
				pc_clk <= '0' after propDelay; -- pc not used here
				op2_clk <= '0' after propDelay; -- op2 not used here (used in the next state)
				result_clk <= '0' after propDelay; -- result not yet used
				
				state := 4; 
			when 4 => 
				-- ALU op: load op2 registear from the regfile 
				-- your code here
				-- operand2 variable is an index value*****
				
				regfile_index <= operand2 after propDelay;

				regfile_readnotwrite <= '1' after propDelay; -- reading from the reg file

				-- clocks: only op2_clk and regfile_clk are 1 since they're used, everything else is 0
				regfile_clk <= '1' after propDelay;
				op2_clk <= '1' after propDelay;
				mem_clk <= '0' after propDelay; -- memory not used here
				ir_clk <= '0' after propDelay; -- instr register not used here
				imm_clk <= '0' after propDelay; -- imm reg not used here
				addr_clk <= '0' after propDelay; -- addr reg not used here
				pc_clk <= '0' after propDelay; -- pc not used here
				op1_clk <= '0' after propDelay; -- op2 not used here (used in the next state)
				result_clk <= '0' after propDelay; -- result not yet used
	
         			state := 5; 
			when 5 => 
				-- ALU op:  perform ALU operation
				-- your code here

				alu_func <= opcode(3 downto 0) after propDelay; -- **** i think this is the correct partition of the opcode -> waiting for Dr. Chapman email response
				
				-- Only using result here:
				result_clk <= '1' after propDelay;
				regfile_clk <= '0' after propDelay;
				mem_clk <= '0' after propDelay;
				ir_clk <= '0' after propDelay;
				imm_clk <= '0' after propDelay;
				addr_clk <= '0' after propDelay;
				pc_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				
            			state := 6; 
			when 6 => 
				-- ALU op: write back ALU operation
				-- your code here

				-- Now that the instruction has been performed and written back, use pcplusone

				regfile_readnotwrite <= '0' after propDelay; -- done reading regfile, writing now

				-- Multiplexers:
				pc_mux <= '0' after propDelay;
				regfilein_mux <= "00" after propDelay;

				-- Clocks:
				pc_clk <= '1' after propDelay; -- pcplusone
				regfile_clk <= '1' after propDelay; -- writing to regfile
				mem_clk <= '0' after propDelay;
				ir_clk <= '0' after propDelay;
				imm_clk <= '0' after propDelay;
				addr_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				result_clk <= '0' after propDelay;

            			state := 1; 
			when 7 => 
				-- LD or LDI: get the addr or immediate word
			   	-- your code here 

				-- LD -> X30, LDI -> X31
				-- Both cases:
				mem_readnotwrite <= '1' after propDelay;

				-- Multiplexers:
				pc_mux <= '0' after propDelay;
				memaddr_mux <= "00" after propDelay;

				-- Clocks:
				pc_clk <= '1' after propDelay;
				mem_clk <= '1' after propDelay;
				regfile_clk <= '0' after propDelay;
				ir_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				result_clk <= '0' after propDelay;

				if opcode = X"30" then
					-- Multiplexers:
					addr_mux <= '1' after propDelay;
						
					-- Clocks:					
					addr_clk <= '1' after propDelay;
					imm_clk <= '0' after propDelay;
				else
					-- Clocks:
					imm_clk <= '1' after propDelay;
					addr_clk <= '0' after propDelay;
				end if;
				state := 8; 
			when 8 => 
				-- LD or LDI
				-- your code here
				
				-- Destination is a register index*****
				-- Both cases:
				regfile_index <= destination after propDelay;
				regfile_readnotwrite <= '0' after propDelay;

				pc_mux <= '0' after propDelay;

				regfile_clk <= '1' after propDelay;
				ir_clk <= '0' after propDelay;
				addr_clk <= '0' after propDelay;
				pc_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				result_clk <= '0' after propDelay;

				if opcode = X"30" then
					mem_readnotwrite <= '1' after propDelay;

					-- Multiplexers:
					memaddr_mux <= "01" after propDelay;
					regfilein_mux <= "01" after propDelay;
					
					-- Clocks:
					mem_clk <= '1' after propDelay;
					imm_clk <= '0' after propDelay;
				else
					-- Multiplexers:
					regfilein_mux <= "10" after propDelay;
					
					-- Clocks:
					imm_clk <= '1' after propDelay;
					mem_clk <= '0' after propDelay;
				end if;
        			state := 1; 
			when 9 =>
				pc_mux <= '0' after propDelay;
				pc_clk <= '1' after propDelay;

				-- everything else low:
				regfile_clk <= '0' after propDelay;
				mem_clk <= '0' after propDelay;
				ir_clk <= '0' after propDelay;
				imm_clk <= '0' after propDelay;
				addr_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				result_clk <= '0' after propDelay;

				state := 10;

			when 10 =>
				-- Mem[PC] -> Addr

				mem_readnotwrite <= '1' after propDelay;

				-- Multiplexers:
				memaddr_mux <= "00" after propDelay;
				addr_mux <= '1' after propDelay;
				
				-- Clocks:
				mem_clk <= '1' after propDelay;
				addr_clk <= '1' after propDelay;
				regfile_clk <= '0' after propDelay;
				ir_clk <= '0' after propDelay;
				imm_clk <= '0' after propDelay;
				pc_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				result_clk <= '0' after propDelay;

				state := 11;

			when 11 =>
				regfile_readnotwrite <= '1' after propDelay;
				mem_readnotwrite <= '0' after propDelay;
				
				-- operand1 is the source here
				regfile_index <= operand1 after propDelay;

				-- Multiplexers:
				memaddr_mux <= "00" after propDelay;
				pc_mux <= '1' after propDelay;

				-- Clocks:
				regfile_clk <= '1' after propDelay;
				mem_clk <= '1' after propDelay;
				pc_clk <= '1' after propDelay;
				ir_clk <= '0' after propDelay;
				imm_clk <= '0' after propDelay;
				addr_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				result_clk <= '0' after propDelay;

				state := 1;

			when 12 => 
				regfile_readnotwrite <= '1' after propDelay;
				regfile_index <= operand1 after propDelay;

				-- Multiplexers:
				addr_mux <= '0' after propDelay;
				
				-- Clocks:
				regfile_clk <= '1' after propDelay;
				addr_clk <= '1' after propDelay;
				mem_clk <= '0' after propDelay;
				ir_clk <= '0' after propDelay;
				imm_clk <= '0' after propDelay;
				pc_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				result_clk <= '0' after propDelay;

				state := 13;

			when 13 =>
				mem_readnotwrite <= '1' after propDelay;
				regfile_readnotwrite <= '0' after propDelay;
				regfile_index <= destination after propDelay;

				-- Multiplexers:
				regfilein_mux <= "01" after propDelay;
				memaddr_mux <= "01" after propDelay;
				pc_mux <= '0' after propDelay;
				
				-- Clocks:
				mem_clk <= '1' after propDelay;
				regfile_clk <= '1' after propDelay;
				pc_clk <= '1' after propDelay;
				ir_clk <= '0' after propDelay;
				imm_clk <= '0' after propDelay;
				addr_clk <= '0' after propDelay;
				op1_clk <= '0' after propDelay;
				op2_clk <= '0' after propDelay;
				result_clk <= '0' after propDelay;

				state := 1;

			when 14 =>

				state := 15;

			when 15 =>

				state := 1;
			
			when 16 =>

				state := 17;

			when 17 =>

				state := 18;

			when 18 =>

				state := 1;

			when 19 =>

				state := 1;
			when others => null; 
		   end case; 
		elsif clock'event and clock = '0' then
			-- reset all the register clocks
		   	-- your code here		
			regfile_clk <= '0' after propDelay;
			mem_clk <= '0' after propDelay;
			ir_clk <= '0' after propDelay;
			imm_clk <= '0' after propDelay;
			addr_clk <= '0' after propDelay;
			pc_clk <= '0' after propDelay;
			op1_clk <= '0' after propDelay;
			op2_clk <= '0' after propDelay;
			result_clk <= '0' after propDelay;		
		end if; 
	end process behav;
end behavior;	