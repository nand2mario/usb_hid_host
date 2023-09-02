
localparam [7:0] SHIFT_MASK = 8'b00100010;
function [7:0] scancode2char(input [7:0] scancode, input [7:0] modifiers); 
    reg [7:0] a;
    if (scancode >= 4 && scancode <= 29) begin   // a-z
        if (modifiers == 0)
            a = scancode - 4 + 97;             // a: 97, A: 65
        else if ((modifiers & SHIFT_MASK) && (modifiers & ~SHIFT_MASK) == 0)
            a = scancode - 4 + 65;
    end else if (modifiers == 0) begin
        case (scancode)
            30: a = "1";
            31: a = "2";
            32: a = "3";
            33: a = "4";
            34: a = "5";
            35: a = "6";
            36: a = "7";
            37: a = "8";
            38: a = "9";
            39: a = "0";
            40: a = "\n";       // enter
            41: a = 27;         // esc
            42: a = 8;          // backspace
            43: a = 9;          // tab
            44: a = 32;         // space
            45: a = "-";        // -
            46: a = "=";        // =
            47: a = "[";        // [
            48: a = "]";        // ]
            49: a = "\\";       // \
            50: a = "#";        // non-use # ~
            51: a = ";";        // ;
            52: a = "'";        // '
            53: a = "`";        // `
            54: a = ",";        // ,
            55: a = ".";        // .
            56: a = "/";        // /
            57: ;               // caps lock
        endcase
    end if ((modifiers & SHIFT_MASK) && (modifiers & ~SHIFT_MASK) == 0) begin
        // shift down
        case (scancode)
            30: a = "!";
            31: a = "@";
            32: a = "#";
            33: a = "$";
            34: a = "%";
            35: a = "^";
            36: a = "&";
            37: a = "*";
            38: a = "(";
            39: a = ")";
            40: a = "\n";
            40: a = "\n";       // enter
            41: a = 27;         // esc
            42: a = 8;          // backspace
            43: a = 9;          // tab
            44: a = 32;         // space
            45: a = "_";
            46: a = "+";
            47: a = "{"; 
            48: a = "}";
            49: a = "|";
            50: a = "~";
            51: a = ":";
            52: a = "\"";
            53: a = "~";
            54: a = "<";
            55: a = ">";
            56: a = "?";
            57: ;
        endcase 
    end
    scancode2char = a;
endfunction
