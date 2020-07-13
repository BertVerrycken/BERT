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

begin

  a4988_proc: process(clk, rst_n)
    variable toggle: std_logic;
  begin
    if (rst_n = '0') then
      step      <= '0';
      dir       <= '0';
      toggle    := '0';
    elsif rising_edge(clk) then
      step      <= toggle;
      dir       <= toggle;
      toggle    := not(toggle);
    end if;
  end process;

end architecture;
