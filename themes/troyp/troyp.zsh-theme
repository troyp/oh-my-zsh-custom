#                                                            -*- shell-script -*-
# ,--------------,
# | working area |
# '--------------'

chars="
┏━┳━┓
┗━┻━┛
┃┣┫╋╺╹╸╻╏╍❰❱
┌─┬─┐
└─┴─┘
│├┤┼╶╵╴╷╎╌❬❭〈〉
⟪⟫⦑⦒⧼⧽〈〉《》︽︾︿﹀
"

# -------------------------------------------------------------------------------
# ,-------------------,
# | utility functions |
# '-------------------'

function getlen() {
    # http://stackoverflow.com/questions/10564314/
    local zero='%([BSUbfksu]|([FBK]|){*})';
    echo ${#${(S%%)1//$~zero/}};
}

function strrep() {
    printf "$1%.0s" {1..$2};
}

# -------------------------------------------------------------------------------
# ,--------,
# | prompt |
# '--------'

# inspired by Ayatoli's prompt (ayozone.org)

function get_prompt() {
    adjustment=3;
    cols="${3:-$COLUMNS}";
    left_width=$((cols - adjustment));
    # list colours with `spectrum_ls`
    FG1="$FG[$1]";
    FG2="$FG[$2]";


    datestr="$(date '+%H:%M, %a %d %b %y')";
    datestrlen=`getlen "$datestr"`;
    dirstr="${PWD/$HOME/~}";
    dirstrlen=`getlen "$dirstr"`;
    if ((dirstrlen > left_width - 9)); then
        dirstr_trunc_len=$((dirstrlen - left_width + 9));
    else
        dirstr_trunc_len=$dirstrlen;
    fi;
    dirstr_adj="$dirstr[1,$dirstr_trunc_len]";

    left="┏━❰$datestr❱━❰$dirstr_adj❱━";
    left_col="$FG2┏━❰$FG1$datestr$FG2❱━❰$FG1$dirstr_adj$FG2❱━";
    left_len=`getlen $left_col`;
    left_padding=`strrep '━' $((left_width - left_len - 1))`
    left_padded="$left${left_padding}┫";
    left_col_padded="$left_col${left_padding}┫";
    left2_col="┗━━❰%{$FG1%}%!%{$FG2%}❱━┛";
    printf "%s\n%s" "$left_col_padded" "$left2_col %{$reset_color%}";
}
PROMPT="\$(get_prompt 011 001)";

# -------------------------------------------------------------------------------
