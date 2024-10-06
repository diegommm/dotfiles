#!/bin/sh

# fruit service
export __FRUIT_OF_CHOICE="";
__FRUIT_NAMES="grapes melon watermelon tangerine lemon banana pineapple mango red_apple green_apple pear peach cherries strawberry blueberries kiwi tomato olive coconut";
__THE_FRUITS_THEMSELVES="🍇 🍈 🍉 🍊 🍋 🍌 🍍 🥭 🍎 🍏 🍐 🍑 🍒 🍓 🫐 🥝 🍅 🫒 🥥";
__get_fruit_by_name(){
    i=0;
    found=0;
    for name in ${__FRUIT_NAMES}; do
        i=$(( i+1 ));
        if [ "$1" = "${name}" ]; then
            found=1;
            break;
        fi;
    done;

    if [ "${found}" -eq 0 ]; then
        echo "Hmmm, I had a few ${1}s last week but no one asked for them and" \
            "they rotted away. Try running 'list_fruits' to see what's" \
            "featured on the shelf today" >&2;
        return 1;
    fi;

    for fruit in ${__THE_FRUITS_THEMSELVES}; do
        i=$(( i-1 ));
        if [ "${i}" = 0 ]; then
            echo "${fruit}";
            return 0;
        fi;
    done;
}
__set_fruit(){
    chosen_fruit="$(__get_fruit_by_name "$1";)";
    if [ -z "${chosen_fruit}" ]; then
        return 1;
    fi;
    export __FRUIT_OF_CHOICE="${chosen_fruit}";
    if echo "${TERM}" | grep -q screen; then
        screen -X title "In this window we eat ${1}";
    fi;
}
__pick_a_fruit(){
    read -r fruit;
    if [ -n "${fruit}" ]; then
        if __set_fruit "${fruit}"; then
            echo "There you go, just beware they're extra juicy, enjoy!";
        fi;
    fi;
}
list_fruits(){
    echo "These are the fruits featured this week:";
    for name in ${__FRUIT_NAMES}; do
        echo "    The ${name} looks like this:" \
            "$(__get_fruit_by_name "${name}" || true;)";
    done;

    echo;
    printf "What would you like to try today? ";
    __pick_a_fruit;
}
om_nom_I_ate_my_fruit_and_it_was_delicious(){
    export __FRUIT_OF_CHOICE="";
    if echo "${TERM}" | grep -q screen; then
        screen -X title "This window ran out of fruit";
    fi;
    printf "Glad you liked it! What would you like to try next? ";
    __pick_a_fruit;
}

export PS1='${__FRUIT_OF_CHOICE}'"${PS1}";
