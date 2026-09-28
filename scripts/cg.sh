#!/usr/bin/env bash

set -e

ROOT="$HOME/public_html"
GIT_ROOT="$ROOT/git"

COMMAND="$1"
COMPONENT="$2"
MESSAGE="${*:3}"

if [ -z "$COMMAND" ]; then
    echo "Usage:"
    echo "  cg new <component>"
    echo "  cg status [component]"
    echo "  cg pull [component]"
    echo "  cg commit <component> \"message\""
    echo "  cg push [component]"
    exit 1
fi

if [ ! -d "$ROOT" ]; then
    echo "ERROR: Public HTML directory does not exist:"
    echo "       $ROOT"
    exit 1
fi

if [ ! -d "$GIT_ROOT" ]; then
    echo "ERROR: Git directory does not exist:"
    echo "       $GIT_ROOT"
    exit 1
fi

run_repo() {
    local component="$1"
    local repo="$GIT_ROOT/$component"

    echo
    echo "========================================"
    echo "Component: $component"
    echo "Git:       $repo"
    echo "========================================"

    if [ ! -d "$repo" ]; then
        echo "ERROR: Repository does not exist."
        return 1
    fi

    case "$COMMAND" in

        status)

            git --git-dir="$repo" \
                --work-tree="$ROOT" \
                status

            ;;

        pull)

            local branch
            local upstream

            branch=$(git \
                --git-dir="$repo" \
                --work-tree="$ROOT" \
                branch --show-current)

            if [ -z "$branch" ]; then
                echo "ERROR: Cannot determine current branch."
                return 1
            fi

            upstream=$(git \
                --git-dir="$repo" \
                --work-tree="$ROOT" \
                rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)

            if [ -n "$upstream" ]; then

                git --git-dir="$repo" \
                    --work-tree="$ROOT" \
                    pull --ff-only

            else

                echo "No upstream branch. Fetching origin..."

                git --git-dir="$repo" \
                    --work-tree="$ROOT" \
                    fetch origin

                if ! git \
                    --git-dir="$repo" \
                    --work-tree="$ROOT" \
                    show-ref --verify --quiet "refs/remotes/origin/$branch"
                then
                    echo "ERROR: Remote branch origin/$branch does not exist."
                    return 1
                fi

                if ! git \
                    --git-dir="$repo" \
                    --work-tree="$ROOT" \
                    rev-parse --verify HEAD >/dev/null 2>&1
                then

                    echo "Local branch has no commits."
                    echo "Checking out origin/$branch..."

                    git --git-dir="$repo" \
                        --work-tree="$ROOT" \
                        checkout -f -B "$branch" "origin/$branch"

                else

                    echo "Setting upstream:"
                    echo "  origin/$branch"

                    git --git-dir="$repo" \
                        --work-tree="$ROOT" \
                        branch --set-upstream-to="origin/$branch" "$branch"

                    echo
                    echo "Pulling..."

                    git --git-dir="$repo" \
                        --work-tree="$ROOT" \
                        pull --ff-only

                fi

            fi

            ;;

        commit)

            local paths=()

            if [ -d "$ROOT/assets/components/$component" ]; then
                paths+=("assets/components/$component")
            fi

            if [ -d "$ROOT/core/components/$component" ]; then
                paths+=("core/components/$component")
            fi

            if [ ${#paths[@]} -eq 0 ]; then
                echo "ERROR: Component files not found:"
                echo "  assets/components/$component"
                echo "  core/components/$component"
                return 1
            fi

            git --git-dir="$repo" \
                --work-tree="$ROOT" \
                add -- "${paths[@]}"

            if git --git-dir="$repo" \
                --work-tree="$ROOT" \
                diff --cached --quiet
            then
                echo "Nothing to commit."
                return 0
            fi

            git --git-dir="$repo" \
                --work-tree="$ROOT" \
                commit -m "$MESSAGE"

            ;;

        push)

            local upstream

            upstream=$(git \
                --git-dir="$repo" \
                --work-tree="$ROOT" \
                rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)

            if [ -n "$upstream" ]; then

                git --git-dir="$repo" \
                    --work-tree="$ROOT" \
                    push

            else

                local branch

                branch=$(git \
                    --git-dir="$repo" \
                    --work-tree="$ROOT" \
                    branch --show-current)

                if [ -z "$branch" ]; then
                    echo "ERROR: Cannot determine current branch."
                    return 1
                fi

                git --git-dir="$repo" \
                    --work-tree="$ROOT" \
                    push --set-upstream origin "$branch"

            fi

            ;;

        *)

            echo "ERROR: Unknown command: $COMMAND"
            echo
            echo "Usage:"
            echo "  cg new <component>"
            echo "  cg status [component]"
            echo "  cg pull [component]"
            echo "  cg commit <component> \"message\""
            echo "  cg push [component]"
            return 1

            ;;

    esac
}

case "$COMMAND" in

    new)

        if [ -z "$COMPONENT" ]; then
            echo "Usage:"
            echo "  cg new <component>"
            exit 1
        fi

        REPO="$GIT_ROOT/$COMPONENT"
        ASSETS="$ROOT/assets/components/$COMPONENT"
        CORE="$ROOT/core/components/$COMPONENT"
        REMOTE="git@github.com:palma-yasen/$COMPONENT.git"

        echo "Component: $COMPONENT"
        echo "Git:       $REPO"
        echo "Remote:    $REMOTE"
        echo

        if [ -e "$REPO" ]; then
            echo "ERROR: Git repository already exists:"
            echo "       $REPO"
            exit 1
        fi

        if [ ! -d "$ASSETS" ]; then
            echo "WARNING: $ASSETS does not exist."
        fi

        if [ ! -d "$CORE" ]; then
            echo "WARNING: $CORE does not exist."
        fi

        echo "Creating repository..."

        mkdir -p "$REPO"

        git --git-dir="$REPO" \
            --work-tree="$ROOT" \
            init

        git --git-dir="$REPO" \
            --work-tree="$ROOT" \
            config user.name "palma-yasen"

        git --git-dir="$REPO" \
            --work-tree="$ROOT" \
            config user.email "palma.yasen@yandex.ru"

        cat > "$REPO/info/exclude" <<EOF
# Ignore everything
*

# Allow component paths
!assets/
!assets/components/
!assets/components/$COMPONENT/
!assets/components/$COMPONENT/**

!core/
!core/components/
!core/components/$COMPONENT/
!core/components/$COMPONENT/**

# Ignore Git metadata
git/
EOF

        git --git-dir="$REPO" \
            --work-tree="$ROOT" \
            remote add origin "$REMOTE"

        echo
        echo "Repository created successfully."
        echo
        echo "Git:"
        echo "  $REPO"
        echo
        echo "GitHub:"
        echo "  $REMOTE"
        echo
        echo "Status:"
        echo

        git --git-dir="$REPO" \
            --work-tree="$ROOT" \
            status

        echo
        echo "Done."

        ;;

    status|pull|commit|push)

        if [ "$COMMAND" = "commit" ]; then

            if [ -z "$COMPONENT" ] || [ -z "$MESSAGE" ]; then
                echo "Usage:"
                echo "  cg commit <component> \"message\""
                exit 1
            fi

        fi

        if [ -n "$COMPONENT" ]; then
            run_repo "$COMPONENT"
            exit $?
        fi

        if [ "$COMMAND" = "commit" ]; then
            echo "ERROR: commit requires a component."
            echo "Usage:"
            echo "  cg commit <component> \"message\""
            exit 1
        fi

        for repo in "$GIT_ROOT"/*; do

            [ -d "$repo" ] || continue

            component="$(basename "$repo")"

            [ -f "$repo/HEAD" ] || continue

            run_repo "$component"

        done

        ;;

    *)

        echo "ERROR: Unknown command: $COMMAND"
        echo
        echo "Usage:"
        echo "  cg new <component>"
        echo "  cg status [component]"
        echo "  cg pull [component]"
        echo "  cg commit <component> \"message\""
        echo "  cg push [component]"
        exit 1

        ;;

esac
