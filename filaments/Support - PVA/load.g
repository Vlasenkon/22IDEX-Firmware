var ttt = 220
G10 S{var.ttt} R{var.ttt} ; Set current tool temperature

M291 R"Warning" P"This material should be printed with front door and LID opened" S2 T5

M98 P"0:/sys/baseload.g"