library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ensc350_package.all;

entity alu is
	 generic (size : integer := 32);
	 PORT
	 ( 
		 in1 : in std_logic_vector(size-1 downto 0);
		 in2 : in std_logic_vector(size-1 downto 0);
		 op : in alu_commands;
		 result : out Std_logic_vector(size-1 downto 0);
		 overflow : out Std_logic 
	 );
end alu;

architecture behavioral of alu is
	signal sum, diff : std_logic_vector(size downto 0);
	signal ucmp, cmp : std_logic_vector(size-1 downto 0);
			
begin
	sum <= std_logic_vector(resize(unsigned(in1),size+1) + resize(unsigned(in2),size+1)); 
	diff <= std_logic_vector(resize(unsigned(in1),size+1) - resize(unsigned(in2),size+1));	 
	ucmp <= std_logic_vector(to_unsigned(1,size)) when unsigned(in1) < unsigned(in2) 
		 else
			std_logic_vector(to_unsigned(0,size));
			cmp <= std_logic_vector(to_unsigned(1,size)) when signed(in1) < signed(in2) 
				 else
					std_logic_vector(to_unsigned(0,size));
					alu_mux: result <= sum(size-1 downto 0) when op=alu_add or op=alu_addu 
						 else
							diff(size-1 downto 0) when op=alu_sub or op=alu_subu 
						 else
							cmp when op=alu_slt 
						 else
							ucmp when op=alu_sltu 
						 else
							in1 and in2 when op=alu_and 
						 else
							in1 or in2 when op=alu_or 
						 else
							in1 xor in2 when op=alu_xor 
						 else
							in1 nor in2 when op=alu_nor 
						else
							std_logic_vector(shift_left(signed(in1), to_integer(signed(in2)))) when op=alu_sll 
						else
							std_logic_vector(shift_right(signed(in1), to_integer(signed(in2)))) when op=alu_srl 
						else
							std_logic_vector(shift_right(signed(in1), to_integer(signed(in2)))) when op=alu_sra 
						else
							in2 (15 downto 0) & x"0000" when op = alu_lui
						else
						 (others=>'0');

 OUTPUT_OVERFLOW: process(in1,in2,sum,diff,op)
 begin
	 overflow <= '0';

	 if op = alu_add and ( in1(size-1) = in2(size-1) ) and ( in1(size-1) /= sum(size-1) ) then
		overflow <= '1';
	 elsif op = alu_sub and ( in1(size-1) /= in2(size-1) ) and ( in1(size-1) /= diff(size-1) ) then
		overflow <= '1';
	 elsif op = alu_addu then
		overflow <= sum(size);
	 elsif op = alu_subu then
		overflow <= diff(size);
	 end if;

 end process;
end behavioral;
