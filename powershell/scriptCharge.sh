r=100
i=0
while ($i -lt $r)
{
    seq 100 | parallel --max-args 0 --jobs 20 " curl -F 'vote=Cats' http://votingappg2-testchargeg2.westus.cloudapp.azure.com/"
    $i++
    sleep 60
}