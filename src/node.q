system "l ",(getenv`QUTIL),"/import.q";
.import.lib`time.q`log.q`conn.q`dz.q`eh.q`event.q`fs.q`timer.q`xxhash.q;

{if[any b:""~/:getenv@'x; .log.fatal"Environment variables not set: ",.Q.s1 x where b; exit 1]}`ConnIntv`ConnTimeout`Hostname`InitNodeNum`PortRange`SchemaPath`TableToHashColumn;
if[not system"p"; .log.fatal"Port number for this process is not set"; exit 1];

.fs.lq@'";"vs getenv`SchemaPath;

\d .node
hpus: {[h;p;u;s]`$":"sv("";h;string p;string u;s)};
hpust: {[h;p;u;s;t](`$":"sv("";h;string p;string u;s);t)};

timeout: "J"$getenv`ConnTimeout;
connectables: hpust[getenv`Hostname;;`$getenv`Username;getenv`Password;timeout]@'{x+til 1+y-x}."I"$"/" vs{x where x in"0123456789/"}getenv`PortRange;
myconn: first connectables where connectables[;0] like "*:",(string system"p"),":*";
nn: "I"$getenv`InitNodeNum;
intv: "N"$getenv`ConnIntv;
peer: ([c:`$()] hash:`s#"j"$(); updt:"p"$());
t2c: (!). flip`$":"vs'";"vs getenv`TableToHashColumn;

.log.info "Started this node [",(string system"p"),"] in cluster (port range:",(getenv`PortRange),"; number of nodes:",(string nn),"; connection timeout:",(string timeout),"; reconnect interval:",(string intv),")";

init: {
    .log.info "Running .node.init[]";
    .conn.init[]; .timer.init[]; .dz.reset`pc; .dz.add[`pc;`.node.pc];
    `hash xasc `.node.peer upsert (first myconn; .xxhash.h64 string first myconn; .time.p[]);
    .conn.add`name`tag`connectable`ep`interval`h!(first myconn;`distnode;myconn;::;intv;0i);
    .timer.add`valuable`mode`interval!((`.node.ts;::);`NextPlus;intv);
    };
regclt: {
    updp: 0!select from (newp:.conn.hbn[x](`.node.regsrv;y;.time.p[])) where not c in (x,y,exec c from .node.peer);
    .log.info "Getting latest peer: ",.Q.s1 updp`c;
    `hash xasc `.node.peer upsert newp;
    .conn.add@'([]name:names;tag:`distnode;connectable:(updp`c),\:timeout;ep:(`.node.regclt;;first myconn)@'names:first@'updp`c;interval:intv;h:0Ni)
    };
regsrv: {
    `hash xasc `.node.peer upsert (x;.xxhash.h64 string x;y);
    .conn.add`name`tag`connectable`ep`interval`h!(x;`distnode;x,timeout;::;intv;.z.w);
    .log.info "New node registered - Current cluster:\n",.Q.s peer;
    peer
    };
h2h: { .conn.hbn flip exec name:c(hash binr x)mod count i from .node.peer };
ts: { if[nn<=count peer;:1b]if[not null first hi:{[c;x]if[(x[1]>=count c)|not null x 0;:x];(@[hopen;c x 1;0Ni];1+x 1)}[otherConn:{x where not x[;0]in exec c from .node.peer}connectables]/[(0Ni;0)];.conn.add`name`tag`connectable`ep`interval`h!(fhc;`distnode;hc;(`.node.regclt;fhc:first hc:otherConn -1+last hi;first myconn);intv;first hi)] };
pc: {
    if[null name:first exec name from .conn.reg where h=x;:()];
    delete from `.node.peer where c=name; .conn.rm name;
    .log.info "Peer ",(string name)," disconnected - Current cluster:\n",.Q.s peer;
    };

\d .
isReady: { .node.nn <= count .node.peer };

upd: {[t;x] (neg exec nodeH from x)@'(insert;t;)@'flip@'value x:?[x;();(enlist`nodeH)!enlist(.Q.fu;`.node.h2h;(`.xxhash.h64;.node.t2c t));c!c:key flip 0!x] };

.node.init[]