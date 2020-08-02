--MIT License
--
-- Copyright (c) 2020, Bert Verrycken, bertv@verrycken.com
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


architecture rtl of motorctrl_a4988 is

  -- Make it locally static (VHDL quirk)
  constant C_AD_WIDTH: natural := G_AD_WIDTH;

  -- Define address map in words (32-bit wide):
  -- => Configuration of the motor
  -- => Status of the motor<
  constant c_addr_config : natural := 0;
  constant c_addr_status : natural := 1;
begin
  -- Motor driver IC process for A4988 board
  a4988_proc: process(clk, rst_n)
    variable toggle:    std_logic;
    variable ReadBusy:  boolean;
    variable WriteBusy: boolean;
    variable WrespBusy: boolean;
    -- Registered version of addresses
    variable ReadAddr:  natural range 0 to 2**C_AD_WIDTH-1;
    variable WriteAddr: natural range 0 to 2**C_AD_WIDTH-1;
    -- Registers
    variable RegStatus: std_logic_vector(G_D_WIDTH-1 downto 0);
    variable RegConfig: std_logic_vector(G_D_WIDTH-1 downto 0);
  begin
    if (rst_n = '0') then
      step      <= '0';
      dir       <= '0';
      toggle    := '0';
      ReadBusy  := false;
      WriteBusy := false;
      WrespBusy := false;
      ReadAddr  := 0;
      WriteAddr := 0;
      axils_s2m <= axil_s2m_init;
    elsif rising_edge(clk) then
      step      <= toggle;
      dir       <= toggle;
      toggle    := not(toggle);
      -- ADDRESS and DATA PHASE are decoupled in AXI protocol
      axils_s2m.ar.ready        <= '0';
      axils_s2m.aw.ready        <= '0';
      axils_s2m.w.ready         <= '0';
      axils_s2m.r.valid         <= '0';
      axils_s2m.r.data          <= (others => '0');
      -- ===============================
      -- == READ: DATA PHASE          ==
      -- ===============================
      if ReadBusy then
        -- Slave has received address, slave asserts read data valid
        axils_s2m.r.valid       <= '1';
        ReadBusy                := false;
        axils_s2m.r.resp        <= axi_response_ok;
        case (ReadAddr) is
          when c_addr_config =>
            axils_s2m.r.data    <= RegConfig;
          when c_addr_status =>
            axils_s2m.r.data    <= RegStatus;
          when others =>
            -- Undefined register, error response
            axils_s2m.r.resp    <= axi_response_decerr;
        end case;
      end if;
      -- ===============================
      -- == READ: ADDRESS PHASE       ==
      -- ===============================
      -- If the slave is selected for read access
      if (axils_rsel) then
        -- Master: ar_valid (address valid), r_ready (ready to accept data)
        if (axils_m2s.ar.valid = '1') then
          -- Slave: address ready + capture address
          axils_s2m.ar.ready    <= '1';
          ReadBusy              := false;
          -- 32-bit addressing: drop lower two bits (byte address)
          ReadAddr              :=
              to_integer(unsigned(axils_m2s.ar.addr(C_AD_WIDTH+1 downto 2)));
          case (ReadAddr) is
            when c_addr_config|c_addr_status =>
              ReadBusy          := true;
            when others =>
              null;
          end case;
        end if;
      end if;
      -- ===============================
      -- == WRITE: RESPONSE PHASE     ==
      -- ===============================
      -- The master must acknowledge the write response is seen
      if WrespBusy then
        if axils_m2s.b.ready = '1' then
          -- Slave has received address, slave asserts 
          axils_s2m.b.valid     <= '0';
          WrespBusy             := false;
        end if;
      end if;
      -- ===============================
      -- == WRITE: DATA PHASE         ==
      -- ===============================
      if WriteBusy then
        if axils_m2s.w.valid = '1' then
          -- Slave has received address, slave asserts 
          axils_s2m.w.ready     <= '1';
          axils_s2m.b.valid     <= '1';
          WriteBusy             := false;
          WrespBusy             := true;
          axils_s2m.b.resp      <= axi_response_ok;
          case (WriteAddr) is
            when c_addr_config =>
              RegConfig         := axils_m2s.w.data;
            when c_addr_status =>
              RegStatus         := axils_m2s.w.data;
            when others =>
              axils_s2m.b.resp  <= axi_response_decerr;
          end case;
        end if;
      end if;
      -- ===============================
      -- == WRITE: ADDRESS PHASE      ==
      -- ===============================
      -- If the slave is selected for read access
      if (axils_wsel) then
        -- Master: ar_valid (address valid), r_ready (ready to accept data)
        if (axils_m2s.aw.valid = '1') then
          -- Slave: address ready + capture address
          axils_s2m.aw.ready    <= '1';
          WriteBusy             := false;
          -- 32-bit addressing: drop lower two bits (byte address)
          case (ReadAddr) is
            when c_addr_config|c_addr_status =>
              WriteBusy         := true;
              WriteAddr         :=
                to_integer(unsigned(axils_m2s.aw.addr(C_AD_WIDTH+1 downto 2)));
            when others =>
              null;
          end case;
        end if;
      end if;
    end if;
  end process;

end architecture;
