#                                                            -*- shell-script -*-
# ,--------------,
# | working area |
# '--------------'

local chars="
┏━┳━┓
┗━┻━┛
┃┣┫╋╺╹╸╻╏╍❰❱
┌─┬─┐
└─┴─┘
│├┤┼╶╵╴╷╎╌❬❭〈〉
⟪⟫⦑⦒⧼⧽〈〉《》︽︾︿﹀✗✓✔❌𐄂
"

# -------------------------------------------------------------------------------
# ,-------------------,
# | utility functions |
# '-------------------'

getlen() {
    # http://stackoverflow.com/questions/10564314/
    local zero='%([BSUbfksu]|([FBK]|){*})';
    echo ${#${(S%%)1//$~zero/}};
}

strrep() {
    printf "$1%.0s" {1..$2};
}

prompt_hook() {
    # override to perform command for each new line in shell
    ;
}

# -------------------------------------------------------------------------------
# ,--------,
# | prompt |
# '--------'

get_prompt() {
    # inspired by Ayatoli's prompt (ayozone.org)
    local error="${?:0:1}";
    local adjustment=3;
    local cols="${4:-$COLUMNS}";
    local left_width=$((cols - adjustment));

    local FG1="$FG[$1]";
    local FG2="$FG[$2]";
    local FG3="${FG[$3]:-$FG1}";
    local FG4="$FG[$2]";
    if (( error > 0 )); then FG4="$FG[009]"; fi

    local datestr="$(date '+%H:%M, %a %d %b %y')";
    local datestrlen=`getlen "$datestr"`;
    local dirstr="${PWD/$HOME/~}";
    local dirstr_adj="$dirstr";
    while ((`getlen "$dirstr_adj"` > left_width - 9)); do
        dirstr_adj=`print ${(S)dirstr_adj/?*\//}`; done;
    local dirstr_adj_path="${dirstr_adj%/*}/";
    if [ "$dirstr_adj" = "~" ]; then
        dirstr_adj_path="";
    fi
    local dirstr_adj_dir="${dirstr_adj##*/}";

    local left="┏━❰$datestr❱━❰$dirstr_adj❱━";
    local left_col="$FG4┏━$FG2❰$FG1$datestr$FG2❱━❰$FG1$dirstr_adj_path$FG3$dirstr_adj_dir$FG2❱━";
    local left_len=`getlen $left_col`;
    local left_padding=`strrep '━' $((left_width - left_len - 1))`
    local left_padded="$left${left_padding}┫";
    local left_col_padded="$left_col${left_padding}┫";
    local left2_col="$FG4┗━$FG2❰%{$FG3%}%!%{$FG2%}❱━❱❱$(git_prompt_info)";

    eval "$prompt_hook";

    printf "%s\n%s" "$left_col_padded" "$left2_col %{$reset_color%}";
}

PROMPT="\$(get_prompt 111 003 047)";
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG[047]%}git:%{$FG[111]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$FG[003]❱❱$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$FG[009]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$FG[190]%}✔"

# -------------------------------------------------------------------------------

