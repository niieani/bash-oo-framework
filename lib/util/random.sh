gen_random() {
    MINRND=$1;
    MAXRND=$2;
    RANGE=$(($MAXRND-$MINRND+1));
    RNDRESULT=$RANDOM;
    let "RNDRESULT %= $RANGE";
    RNDRESULT=$(($RNDRESULT+$MINRND));
    return $RNDRESULT
}