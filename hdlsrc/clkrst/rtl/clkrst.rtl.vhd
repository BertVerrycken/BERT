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

architecture rtl of clkrst is

  signal rst_n_z1: std_logic;
  signal rst_n_z2: std_logic;

begin

  sysrst_n              <= rst_n_z2;
  sysclk                <= clk; -- Use the clock pin as system clock

  -- The reset is entered asynchronously whenever the reset external pin is
  -- pulled active low. The reset exits synchronous on the rising edge of the
  -- clock to make sure all flipflops exit the reset state in a clean way.
  process_rst_sync:process(clk, rst_n)
  begin
    if (rst_n = '0') then
      rst_n_z1            <= '1';
      rst_n_z1            <= '1';
    elsif (rising_edge(clk)) then
      -- Double flip-flop synchronizer
      rst_n_z1            <= rst_n;
      rst_n_z2            <= rst_n_z1;
    end if;
  end process;

end architecture;
