cd q-util && source qutil_profile && cd ..

export QLIB="${QLIB};$(pwd)/src"

export ConnIntv="00:00:10"
export ConnTimeout="1000"
export Hostname="localhost"
export PortRange="$Hostname:8000/8005"
export InitNodeNum="2"
export TableToHashColumn="trade:sym;quote:venue"
export SchemaDir="$(pwd)/schema"
export SchemaPath="$SchemaDir/trade.q;$SchemaDir/quote.q"