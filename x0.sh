#!/bin/bash

values=("." "." "." "." "." "." "." "." ".")

if [[ -p "/tmp/x0_fifo" ]]
then
    turn="other"
    my_char="0"
    other_char="x"
else
    mkfifo "/tmp/x0_fifo"
    turn="my"
    my_char="x"
    other_char="0"
fi

function display_table {
    clear
    echo "You are $my_char"
    echo "┌───┬───┬───┐"
    echo "│ $1 │ $2 │ $3 │"
    echo "├───┼───┼───┤"
    echo "│ $4 │ $5 │ $6 │"
    echo "├───┼───┼───┤"
    echo "│ $7 │ $8 │ $9 │"
    echo "└───┴───┴───┘"
}

function clean_fifo {
    if [[ $my_char == '0' ]]
    then
        rm "/tmp/x0_fifo"
    fi
}


function display_cell_numbers {
    echo "┌────┬────┬────┐"
    echo "│ 00 │ 01 │ 02 │"
    echo "├────┼────┼────┤"
    echo "│ 10 │ 11 │ 12 │"
    echo "├────┼────┼────┤"
    echo "│ 20 │ 21 │ 22 │"
    echo "└────┴────┴────┘"
}

function call_win {
    display_table ${values[*]}
    echo "$1 win"
    exit
}

function check_win {
    if [[ $1 == $2 && $2 == $3 && ($1 == 'x' || $1 == '0') ]]
    then
        call_win $1
    fi
    if [[ $4 == $5 && $5 == $6 && ($4 == 'x' || $4 == '0') ]]
    then
        call_win $4
    fi
    if [[ $7 == $8 && $8 == $9 && ($7 == 'x' || $7 == '0') ]]
    then
        call_win $7
    fi

    if [[ $1 == $4 && $4 == $7 && ($1 == 'x' || $1 == '0') ]]
    then
        call_win $1
    fi
    if [[ $2 == $5 && $5 == $8 && ($2 == 'x' || $2 == '0') ]]
    then 
        call_win $2
    fi
    if [[ $3 == $6 && $6 == $9 && ($3 == 'x' || $3 == '0')]]
    then
        call_win $3
    fi

    if [[ $1 == $5 && $5 == $9 && ($1 == 'x' || $1 == '0') ]]
    then
        call_win $1
    fi
    if [[ $3 == $5 && $5 == $7 && ($3 == 'x' || $3 == '0') ]]
    then
        call_win $3
    fi
}

trap clean_fifo EXIT

while true 
do
    if [[ $turn == "my" ]]
    then
        display_table ${values[*]}
        echo "Enter cell number"
        display_cell_numbers
        read -n 2 cell_number
        x=${cell_number:0:1}
        y=${cell_number:1:1}
        while true
        do
            if [[ ($x != "0" && $x != "1" && $x != "2") || 
                  ($y != "0" && $y != "1" && $y != "2") ]]
            then
                echo "Wrong cell number. Try again"
                read -n 2 cell_number
                x=${cell_number:0:1}
                y=${cell_number:1:1}
                continue
            fi
            if [ ${values[$((3*$x + $y))]} != "." ]
            then
                echo ""
                echo "Cell is already set. Try again"
                read -n 2 cell_number
                x=${cell_number:0:1}
                y=${cell_number:1:1}
                continue
            fi
            break
        done
        values[$((3*$x + $y))]=$my_char
        display_table ${values[*]}
        echo $cell_number > "/tmp/x0_fifo"
        turn="other"
    else
        display_table ${values[*]}
        cell_number="$(cat "/tmp/x0_fifo")"
        x=${cell_number:0:1}
        y=${cell_number:1:1}
        echo $cell_number
        values[$((3*$x + $y))]=$other_char
        turn="my"
    fi
    check_win ${values[*]}
done