Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY Tea_tb IS
END Tea_tb;

ARCHITECTURE test OF Tea_tb IS
	COMPONENT Tea
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
END COMPONENT;

		SIGNAL	clk_tb  :std_logic := '0';
		SIGNAL	v0_tb   :std_logic_vector (31 downto 0);
		SIGNAL	v1_tb   :std_logic_vector (31 downto 0);

		SIGNAL	k0_tb   :std_logic_vector (31 downto 0);
		SIGNAL	k1_tb   :std_logic_vector (31 downto 0);
		SIGNAL	k2_tb   :std_logic_vector (31 downto 0);
		SIGNAL	k3_tb   :std_logic_vector (31 downto 0);


		SIGNAL	out0_tb  :std_logic_vector (31 downto 0);
		SIGNAL	out1_tb  :std_logic_vector (31 downto 0);
		
		BEGIN
		cut:	Tea PORT MAP(clk_tb, v0_tb, v1_tb, k0_tb, k1_tb, k2_tb, k3_tb, out0_tb, out1_tb);
	
			clk_tb <= not clk_tb AFTER 10 ns;
			
			v0_tb <=	x"5aba779e";
			v1_tb <=	x"5136036a";
			
			k0_tb <=	x"b4eab864";
			k1_tb <=	x"daa01780";
			k2_tb <=	x"f32b7744";
			k3_tb <= x"99fa2351";
END test;