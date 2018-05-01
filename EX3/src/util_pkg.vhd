------------------------------------------------------
--Author: Jan Nausner <e01614835@student.tuwien.ac.at>
------------------------------------------------------

library ieee;
use iee.std_logic_1164.all;
use iee.numeric_std.all;

package util_pkg is

    function padding(size : natural; val  : std_logic) return std_logic_vector;

end package

package body util_pkg is
    
    function padding(size : natural;
                     val  : std_logic)
                    return std_logic_vector is
        variable padding : std_logic_vector(size-1 downto 0);
    begin
        for i in size-1 downto 0 loop
            padding(i) := val;
        end loop;
        return padding;
    end function;

end package body;

