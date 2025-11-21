LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY spi_flash_controller IS
    PORT (
        -- Processor Interface
        clk        : IN  STD_LOGIC;
        rst        : IN  STD_LOGIC;
        chipSel    : IN  STD_LOGIC;
        readMem    : IN  STD_LOGIC;
        addressBus : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
        dataIn     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        dataOut    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ready      : OUT STD_LOGIC;
        
        -- SPI Flash Interface (corrected directions)
        SCK        : OUT STD_LOGIC;
        CSbar      : OUT STD_LOGIC;
        DI         : OUT STD_LOGIC;
        DO         : IN  STD_LOGIC
    );
END spi_flash_controller;

ARCHITECTURE Arch OF spi_flash_controller IS
    TYPE state_type IS (IDLE, LOAD_CMD, CMD_ADR_SEND, CMD_ADR_CLK, RECEIVE_DATA, RECEIVE_DATA_CLK, DONE);
    SIGNAL pstate, nstate : state_type;
    
    -- Clock generation SIGNALs
    SIGNAL ld_cmd		: STD_LOGIC := '0';
	SIGNAL shift_cmd	: STD_LOGIC := '0';
	SIGNAL shift_rdata	: STD_LOGIC := '0';
	SIGNAL en_cnt_32	: STD_LOGIC := '0';
	SIGNAL en_cnt_8		: STD_LOGIC := '0';
	SIGNAL clr_cnt_8	: STD_LOGIC := '0';
	SIGNAL clr_cnt_32	: STD_LOGIC := '0';
	SIGNAL co_32		: STD_LOGIC := '0';
	SIGNAL co_8			: STD_LOGIC := '0';
    
    SIGNAL cmd_adr_shift_reg	: STD_LOGIC_VECTOR(31 DOWNTO 0)	:= (others => '0');
	SIGNAL rdata_shift_reg		: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= (others => '0');
	SIGNAL cnt_32				: STD_LOGIC_VECTOR(5 DOWNTO 0)	:= (others => '0');
	SIGNAL cnt_8				: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= (others => '0');
    
    
BEGIN
	-- DP --
	-- TO_MEM shift register
	CMD_ADR_SR: PROCESS (clk, rst)
    BEGIN
		IF rst = '1' THEN
			cmd_adr_shift_reg <= (OTHERS=>'0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF ld_cmd = '1' THEN
				cmd_adr_shift_reg <= "00000011" & addressBus;
			ELSIF shift_cmd = '1' THEN
				cmd_adr_shift_reg <= cmd_adr_shift_reg (30 DOWNTO 0) & '0';
			END IF;
		END IF;
    END PROCESS;
	DI <= cmd_adr_shift_reg(31);
	
	-- FROME_MEM shift register
	R_DATA_SR: PROCESS (clk, rst)
    BEGIN
		IF rst = '1' THEN
			rdata_shift_reg <= (OTHERS=>'0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF shift_rdata = '1' THEN
				rdata_shift_reg <= rdata_shift_reg (6 DOWNTO 0) & DO;
			END IF;
		END IF;
    END PROCESS;
	
	-- counters for FSM
	COUNTER_32 : PROCESS( clk )
    BEGIN
		IF rst = '1' THEN
			cnt_32 <= (OTHERS=>'0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF clr_cnt_32 = '1' THEN
				cnt_32 <= (OTHERS=>'0');
			ELSIF en_cnt_32 = '1' THEN
                cnt_32 <= cnt_32 + 1;
            END IF;
		END IF;
    END PROCESS ;
	--co_32 <= cnt_32(5);
	co_32 <= '1' WHEN cnt_32(4 DOWNTO 0) = "11111" ELSE '0';
	
	COUNTER_8 : PROCESS( clk )
    BEGIN
		IF rst = '1' THEN
			cnt_8 <= (OTHERS=>'0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF clr_cnt_8 = '1' THEN
				cnt_8 <= (OTHERS=>'0');
			ELSIF en_cnt_8 = '1' THEN
                cnt_8 <= cnt_8 + 1;
            END IF;
		END IF;
    END PROCESS ;
	--co_8 <= cnt_8(3);
	co_8 <= '1' WHEN cnt_8(2 DOWNTO 0) = "111" ELSE '0';
	
	-- Controller
	SEQ_FSM: PROCESS (clk, rst)
    BEGIN
		IF rst = '1' THEN
			pstate <= IDLE;
		ELSIF clk = '1' AND clk'EVENT THEN 
			pstate <= nstate;
		END IF;
    END PROCESS;
	
	CMB_FSM_NS: PROCESS (pstate, chipSel, readMem, co_32, co_8) BEGIN
        nstate <= IDLE;
        CASE pstate IS
            WHEN IDLE =>
                IF chipSel = '1' and readMem = '1' THEN
					nstate <= LOAD_CMD;
				ELSE
                    nstate <= IDLE;
                END IF ;
                
            WHEN LOAD_CMD =>
				nstate <= CMD_ADR_SEND;
			
			WHEN CMD_ADR_SEND =>
				nstate <= CMD_ADR_CLK;
            
			WHEN CMD_ADR_CLK =>
				IF co_32 = '1' THEN
                    nstate <= RECEIVE_DATA;
				ELSE
					nstate <= CMD_ADR_SEND;
                END IF ;
				
				
			WHEN RECEIVE_DATA =>
				nstate <= RECEIVE_DATA_CLK;
			
			WHEN RECEIVE_DATA_CLK =>
				IF co_8 = '1' THEN
                    nstate <= DONE;
				ELSE
					nstate <= RECEIVE_DATA;
                END IF ;
			
			WHEN DONE =>
				nstate <= IDLE;
			
            WHEN OTHERS=>
        END CASE;
    END PROCESS;
	
	CMB_FSM_O: PROCESS (pstate) BEGIN
        ld_cmd <= '0';
		shift_cmd <= '0';
		shift_rdata <= '0';
		en_cnt_32 <= '0';
		en_cnt_8 <= '0';
		CSbar <= '1';
		SCK <= '0';
		ready <= '0';
		clr_cnt_8 <= '0';
		clr_cnt_32 <= '0';
        CASE pstate IS
            WHEN IDLE =>

            WHEN LOAD_CMD =>    
                ld_cmd <= '1';
				CSbar <= '0';
				clr_cnt_8 <= '1';
				clr_cnt_32 <= '1';
			
			WHEN CMD_ADR_SEND =>    
                
				CSbar <= '0';
				SCK <= '0';
                    
			WHEN CMD_ADR_CLK =>
				shift_cmd <= '1';
				en_cnt_32 <= '1';
				CSbar <= '0';
				SCK <= '1';
				
			WHEN RECEIVE_DATA =>
				CSbar <= '0';
				SCK <= '0';
			
			WHEN RECEIVE_DATA_CLK =>
				shift_rdata <= '1';
				en_cnt_8 <= '1';
				CSbar <= '0';
				SCK <= '1';
			
			WHEN DONE =>
				ready <= '1';
			
            WHEN OTHERS=>

        END CASE;
    END PROCESS;
	
    dataOut <= rdata_shift_reg WHEN chipSel = '1' AND readMem = '1' ELSE (OTHERS => 'Z');
    
END ARCHITECTURE;