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
⟦⟧━⦇⦈━⦉⦊━〚〛━【】━〖〗━〔〕━《》━〘〙
"

# -------------------------------------------------------------------------------
# ,-------------------,
# | utility functions |
# '-------------------'

getlen() {
    # http://stackoverflow.com/questions/10564314/
    local zero='%([BSUbfksu]|([FBK]|){*})';
    local plain=${(S%%)1//$~zero/};

    echo ${#plain}; return
    # printf "$plain" | wc -L
}

strrep() {
    printf "$1%.0s" {1..$2};
}

prompt_hook() {
    # override to perform command for each new line in shell
    ;
}

git-dir-is-dirty() {
    test $(git diff --shortstat 2>>/dev/null | wc -l) != 0;
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
    local FGe="$FG[009]";
    local FGs="$FG[047]";
    if `git-dir-is-dirty`; then
        FG4="$FGe";
    elif [[ -d .git ]]; then
        FG4="$FGs";
    fi

    local datestr="$(date '+%H:%M, %a %d %b %y')";
    local datestrlen=`getlen "$datestr"`;
    local dirstr="${PWD/$HOME/~}";

    # ===========================================================
    # ADJUSTED DIRECTORY: remove path prefixes until short enough
    # ===========================================================
    local dirstr_adj="$dirstr";
    maxlen=$((left_width - 47))
    while ((`getlen "$dirstr_adj"` > maxlen)); do
        if [[ "$dirstr_adj" =~ .*/.* ]]; then
            dirstr_adj=`print ${(S)dirstr_adj/?*\//}`;
        else
            local maxlen_adj=$((maxlen - 3))
            dirstr_adj="${dirstr_adj:0:$maxlen_adj}..."
        fi
    done;

    # =======================
    # ADJUSTED DIRECTORY PATH
    # =======================
    # case "$dirstr_adj" in
    #     ~) dirstr_adj_path="" ;;
    #     *) dirstr_adj_path="{dirstr_adj%/*}"/ ;;
    # esac
    local dirstr_adj_path
    if [[ "$dirstr_adj" =~ .*/.* ]]; then
        dirstr_adj_path="${dirstr_adj%/*}/";
    else
        dirstr_adj_path="";
    fi
    if [ "$dirstr_adj" = "~" ]; then
        dirstr_adj_path="";
    fi

    # =========================
    # ADJUSTED DIRECTORY PROPER
    # =========================
    local dirstr_adj_dir="${dirstr_adj##*/}";

    local left="┏━❰$datestr❱━❰$dirstr_adj❱━";
    # 28 chars + len(dirstr_adj)
    local left_col="$FG4┏━$FG2❰$FG1$datestr$FG2❱━❰$FG1$dirstr_adj_path$FG3$dirstr_adj_dir$FG2❱━";

    if (( error > 0 )); then
        local left_error_suffix="━━━$FG1❰ %{$FGe%}✗ ${FG[011]}error: $error$FG1 ❱$FG2━";
    else
        local left_error_suffix="━━━❰ %{$FGs%}✔ $FG2❱━";
    fi
    # 18 chars (error) or 9 chars (no error)

    local left_len=`getlen $left_col$left_error_suffix`;
    local left_padding=`strrep '━' $((left_width - left_len - 1))`
    local left_padded="$left${left_padding}┫";
    local left_col_padded="$left_col$left_error_suffix${left_padding}┫";
    # (28 + 18 + 1 =) 47 chars + padding
    local left2_col="$FG4┗━$FG2❰%{$FG3%}%!%{$FG2%}❱━❱❱$(git_prompt_info)";

    eval "$prompt_hook";

    printf "%s\n%s" "$left_col_padded" "$left2_col %{$reset_color%}";
}

 git_prompt_setup() {
     local FG1="$FG[$1]";
     local FG2="$FG[$2]";
     local FG3="${FG[$3]:-$FG1}";
     ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG3%}git:%{$FG1%}";
     ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$FG2❱❱$reset_color%}";
     ZSH_THEME_GIT_PROMPT_DIRTY="";
     ZSH_THEME_GIT_PROMPT_CLEAN="";
 }

PROMPT="\$(get_prompt 111 003 047)";
git_prompt_setup 111 003 047;

# -------------------------------------------------------------------------------

