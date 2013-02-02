#!/bin/sh
BRANCH=$1
IGNOREFILE='deploy/.deploy_ignore'

echo '. Starting deploy'

# Check to see if the deploy file exists
if [ ! -f "deploy/.deploy" ];
then
        echo ". You need to create a .deploy file"
        exit 0
fi

if [ -z "$BRANCH" ];
then
    BRANCH="master"
    echo ". No branch defined, looking for default branch 'master'"
        # echo ". No branch has been selected"
        # exit 0
fi

echo '. Deploying' $BRANCH

echo '. Parsing .deploy file'

IFS='
'
for a in `cat deploy/.deploy | grep ^$BRANCH `
do
        IFS=' '
        A=( $a )
        SSH=${A[1]}
        DEPLOYPATH=${A[2]}
        CHMODTRIGGER=${A[3]}
done

# Check SSH
if [ -z "$SSH" ];
then
        echo ". No host has been set for $BRANCH"
        exit 0
fi
# Check deploy path
if [ -z "$DEPLOYPATH" ];
then
        echo ". No path has been set for $BRANCH"
        exit 0
fi

echo ' - SSH:' $SSH
echo ' - PATH:' $DEPLOYPATH

# allow execution of the deployment files
chmod +x ./deploy/.deploy_before
chmod +x ./deploy/.deploy_success


# If the deploy_before file exists, then run it
if [ -f "deploy/.deploy_before" ]
then
        echo '. Launching deploy_before file'
        ./deploy/.deploy_before
fi



echo '. Deploying to' $SSH:$DEPLOYPATH

# If we have an ignore file then use it
if [ -f "$IGNOREFILE" ]
then

        echo ' - Using deploy_ignore file.'

        rsync -rvzpu --executability \
        ./ \
        $SSH:$DEPLOYPATH \
        --exclude-from $IGNOREFILE \

else

        echo ' - Not using deploy_ignore file.'

        rsync -rvzpu --executability \
        ./ \
        $SSH:$DEPLOYPATH \

fi

# If we have a deploy_success file then:
#    - SSH into the server
#    - cd to the deploy folder
#    - execute the script
if [ -f "deploy/.deploy_success" ]
then
        echo '. Launching deploy_success file on remote server'
        ssh $SSH "source ~/env/bin/activate && pip install -r requirements.txt && deactivate"
        ssh $SSH "cd $DEPLOYPATH && ./deploy/.deploy_success $BRANCH"
fi

echo '. Deployment finished'