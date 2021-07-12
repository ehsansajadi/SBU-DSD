Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity tea is
port(
clk : in std_logic;
v0 : in std_logic_vector (31 downto 0);
v1 : in std_logic_vector (31 downto 0);

k0 : in std_logic_vector (31 downto 0);
k1 : in std_logic_vector (31 downto 0);
k2 : in std_logic_vector (31 downto 0);
k3 : in std_logic_vector (31 downto 0);
out0 : out std_logic_vector (31 downto 0);
out1 : out std_logic_vector (31 downto 0)
);

end Tea;

architecture arch of tea is

    signal delta: std_logic_vector(31 downto 0) := x"9E3779B9";
 
        --delta := x"9E3779B9";
	 begin
	
		process (v0, v1, k0, k1, k2, k3)
        variable z, y	: std_logic_vector (31 downto 0);
        variable sum		: std_logic_vector (31 downto 0);

    begin
        y:= v0;
        z:= v1;
		  sum := (OTHERS => '0');
			FOR n in 32 DOWNTO 1 LOOP
			
                        sum:=sum+delta;
								
								y := y + (((z(27 DOWNTO 0) & "0000" + k0) XOR (z + sum) XOR ("00000" & z(31 DOWNTO 5) + k1)));
								
								z := z + (((y(27 DOWNTO 0) & "0000" + k2) XOR (y + sum) XOR ("00000" & y(31 DOWNTO 5) + k3)));        
								
							END LOOP;
							out0 <= y;
							out1 <= z;
end process;
end arch;
