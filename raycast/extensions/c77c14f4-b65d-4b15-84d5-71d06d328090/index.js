"use strict";var Sn=Object.create;var D=Object.defineProperty;var gn=Object.getOwnPropertyDescriptor;var xn=Object.getOwnPropertyNames;var bn=Object.getPrototypeOf,wn=Object.prototype.hasOwnProperty;var a=(e,t)=>()=>(t||e((t={exports:{}}).exports,t),t.exports),vn=(e,t)=>{for(var r in t)D(e,r,{get:t[r],enumerable:!0})},Pe=(e,t,r,n)=>{if(t&&typeof t=="object"||typeof t=="function")for(let s of xn(t))!wn.call(e,s)&&s!==r&&D(e,s,{get:()=>t[s],enumerable:!(n=gn(t,s))||n.enumerable});return e};var Ge=(e,t,r)=>(r=e!=null?Sn(bn(e)):{},Pe(t||!e||!e.__esModule?D(r,"default",{value:e,enumerable:!0}):r,e)),En=e=>Pe(D({},"__esModule",{value:!0}),e);var qe=a((xs,Oe)=>{Oe.exports=Re;Re.sync=Tn;var Ae=require("fs");function In(e,t){var r=t.pathExt!==void 0?t.pathExt:process.env.PATHEXT;if(!r||(r=r.split(";"),r.indexOf("")!==-1))return!0;for(var n=0;n<r.length;n++){var s=r[n].toLowerCase();if(s&&e.substr(-s.length).toLowerCase()===s)return!0}return!1}function Ne(e,t,r){return!e.isSymbolicLink()&&!e.isFile()?!1:In(t,r)}function Re(e,t,r){Ae.stat(e,function(n,s){r(n,n?!1:Ne(s,e,t))})}function Tn(e,t){return Ne(Ae.statSync(e),e,t)}});var Be=a((bs,_e)=>{_e.exports=Le;Le.sync=Cn;var ke=require("fs");function Le(e,t,r){ke.stat(e,function(n,s){r(n,n?!1:$e(s,t))})}function Cn(e,t){return $e(ke.statSync(e),t)}function $e(e,t){return e.isFile()&&Pn(e,t)}function Pn(e,t){var r=e.mode,n=e.uid,s=e.gid,i=t.uid!==void 0?t.uid:process.getuid&&process.getuid(),o=t.gid!==void 0?t.gid:process.getgid&&process.getgid(),c=parseInt("100",8),l=parseInt("010",8),d=parseInt("001",8),p=c|l,y=r&d||r&l&&s===o||r&c&&n===i||r&p&&i===0;return y}});var je=a((vs,Me)=>{var ws=require("fs"),U;process.platform==="win32"||global.TESTING_WINDOWS?U=qe():U=Be();Me.exports=ne;ne.sync=Gn;function ne(e,t,r){if(typeof t=="function"&&(r=t,t={}),!r){if(typeof Promise!="function")throw new TypeError("callback not provided");return new Promise(function(n,s){ne(e,t||{},function(i,o){i?s(i):n(o)})})}U(e,t||{},function(n,s){n&&(n.code==="EACCES"||t&&t.ignoreErrors)&&(n=null,s=!1),r(n,s)})}function Gn(e,t){try{return U.sync(e,t||{})}catch(r){if(t&&t.ignoreErrors||r.code==="EACCES")return!1;throw r}}});var Ve=a((Es,Ke)=>{var T=process.platform==="win32"||process.env.OSTYPE==="cygwin"||process.env.OSTYPE==="msys",Fe=require("path"),An=T?";":":",De=je(),Ue=e=>Object.assign(new Error(`not found: ${e}`),{code:"ENOENT"}),Xe=(e,t)=>{let r=t.colon||An,n=e.match(/\//)||T&&e.match(/\\/)?[""]:[...T?[process.cwd()]:[],...(t.path||process.env.PATH||"").split(r)],s=T?t.pathExt||process.env.PATHEXT||".EXE;.CMD;.BAT;.COM":"",i=T?s.split(r):[""];return T&&e.indexOf(".")!==-1&&i[0]!==""&&i.unshift(""),{pathEnv:n,pathExt:i,pathExtExe:s}},He=(e,t,r)=>{typeof t=="function"&&(r=t,t={}),t||(t={});let{pathEnv:n,pathExt:s,pathExtExe:i}=Xe(e,t),o=[],c=d=>new Promise((p,y)=>{if(d===n.length)return t.all&&o.length?p(o):y(Ue(e));let h=n[d],S=/^".*"$/.test(h)?h.slice(1,-1):h,g=Fe.join(S,e),x=!S&&/^\.[\\\/]/.test(e)?e.slice(0,2)+g:g;p(l(x,d,0))}),l=(d,p,y)=>new Promise((h,S)=>{if(y===s.length)return h(c(p+1));let g=s[y];De(d+g,{pathExt:i},(x,I)=>{if(!x&&I)if(t.all)o.push(d+g);else return h(d+g);return h(l(d,p,y+1))})});return r?c(0).then(d=>r(null,d),r):c(0)},Nn=(e,t)=>{t=t||{};let{pathEnv:r,pathExt:n,pathExtExe:s}=Xe(e,t),i=[];for(let o=0;o<r.length;o++){let c=r[o],l=/^".*"$/.test(c)?c.slice(1,-1):c,d=Fe.join(l,e),p=!l&&/^\.[\\\/]/.test(e)?e.slice(0,2)+d:d;for(let y=0;y<n.length;y++){let h=p+n[y];try{if(De.sync(h,{pathExt:s}))if(t.all)i.push(h);else return h}catch{}}}if(t.all&&i.length)return i;if(t.nothrow)return null;throw Ue(e)};Ke.exports=He;He.sync=Nn});var se=a((Is,re)=>{"use strict";var We=(e={})=>{let t=e.env||process.env;return(e.platform||process.platform)!=="win32"?"PATH":Object.keys(t).reverse().find(n=>n.toUpperCase()==="PATH")||"Path"};re.exports=We;re.exports.default=We});var Ze=a((Ts,Qe)=>{"use strict";var ze=require("path"),Rn=Ve(),On=se();function Ye(e,t){let r=e.options.env||process.env,n=process.cwd(),s=e.options.cwd!=null,i=s&&process.chdir!==void 0&&!process.chdir.disabled;if(i)try{process.chdir(e.options.cwd)}catch{}let o;try{o=Rn.sync(e.command,{path:r[On({env:r})],pathExt:t?ze.delimiter:void 0})}catch{}finally{i&&process.chdir(n)}return o&&(o=ze.resolve(s?e.options.cwd:"",o)),o}function qn(e){return Ye(e)||Ye(e,!0)}Qe.exports=qn});var Je=a((Cs,ie)=>{"use strict";var oe=/([()\][%!^"`<>&|;, *?])/g;function kn(e){return e=e.replace(oe,"^$1"),e}function Ln(e,t){return e=`${e}`,e=e.replace(/(\\*)"/g,'$1$1\\"'),e=e.replace(/(\\*)$/,"$1$1"),e=`"${e}"`,e=e.replace(oe,"^$1"),t&&(e=e.replace(oe,"^$1")),e}ie.exports.command=kn;ie.exports.argument=Ln});var tt=a((Ps,et)=>{"use strict";et.exports=/^#!(.*)/});var rt=a((Gs,nt)=>{"use strict";var $n=tt();nt.exports=(e="")=>{let t=e.match($n);if(!t)return null;let[r,n]=t[0].replace(/#! ?/,"").split(" "),s=r.split("/").pop();return s==="env"?n:n?`${s} ${n}`:s}});var ot=a((As,st)=>{"use strict";var ce=require("fs"),_n=rt();function Bn(e){let r=Buffer.alloc(150),n;try{n=ce.openSync(e,"r"),ce.readSync(n,r,0,150,0),ce.closeSync(n)}catch{}return _n(r.toString())}st.exports=Bn});var ut=a((Ns,at)=>{"use strict";var Mn=require("path"),it=Ze(),ct=Je(),jn=ot(),Fn=process.platform==="win32",Dn=/\.(?:com|exe)$/i,Un=/node_modules[\\/].bin[\\/][^\\/]+\.cmd$/i;function Xn(e){e.file=it(e);let t=e.file&&jn(e.file);return t?(e.args.unshift(e.file),e.command=t,it(e)):e.file}function Hn(e){if(!Fn)return e;let t=Xn(e),r=!Dn.test(t);if(e.options.forceShell||r){let n=Un.test(t);e.command=Mn.normalize(e.command),e.command=ct.command(e.command),e.args=e.args.map(i=>ct.argument(i,n));let s=[e.command].concat(e.args).join(" ");e.args=["/d","/s","/c",`"${s}"`],e.command=process.env.comspec||"cmd.exe",e.options.windowsVerbatimArguments=!0}return e}function Kn(e,t,r){t&&!Array.isArray(t)&&(r=t,t=null),t=t?t.slice(0):[],r=Object.assign({},r);let n={command:e,args:t,options:r,file:void 0,original:{command:e,args:t}};return r.shell?n:Hn(n)}at.exports=Kn});var ft=a((Rs,dt)=>{"use strict";var ae=process.platform==="win32";function ue(e,t){return Object.assign(new Error(`${t} ${e.command} ENOENT`),{code:"ENOENT",errno:"ENOENT",syscall:`${t} ${e.command}`,path:e.command,spawnargs:e.args})}function Vn(e,t){if(!ae)return;let r=e.emit;e.emit=function(n,s){if(n==="exit"){let i=lt(s,t,"spawn");if(i)return r.call(e,"error",i)}return r.apply(e,arguments)}}function lt(e,t){return ae&&e===1&&!t.file?ue(t.original,"spawn"):null}function Wn(e,t){return ae&&e===1&&!t.file?ue(t.original,"spawnSync"):null}dt.exports={hookChildProcess:Vn,verifyENOENT:lt,verifyENOENTSync:Wn,notFoundError:ue}});var ht=a((Os,C)=>{"use strict";var pt=require("child_process"),le=ut(),de=ft();function mt(e,t,r){let n=le(e,t,r),s=pt.spawn(n.command,n.args,n.options);return de.hookChildProcess(s,n),s}function zn(e,t,r){let n=le(e,t,r),s=pt.spawnSync(n.command,n.args,n.options);return s.error=s.error||de.verifyENOENTSync(s.status,n),s}C.exports=mt;C.exports.spawn=mt;C.exports.sync=zn;C.exports._parse=le;C.exports._enoent=de});var St=a((qs,yt)=>{"use strict";yt.exports=e=>{let t=typeof e=="string"?`
`:`
`.charCodeAt(),r=typeof e=="string"?"\r":"\r".charCodeAt();return e[e.length-1]===t&&(e=e.slice(0,e.length-1)),e[e.length-1]===r&&(e=e.slice(0,e.length-1)),e}});var bt=a((ks,L)=>{"use strict";var k=require("path"),gt=se(),xt=e=>{e={cwd:process.cwd(),path:process.env[gt()],execPath:process.execPath,...e};let t,r=k.resolve(e.cwd),n=[];for(;t!==r;)n.push(k.join(r,"node_modules/.bin")),t=r,r=k.resolve(r,"..");let s=k.resolve(e.cwd,e.execPath,"..");return n.push(s),n.concat(e.path).join(k.delimiter)};L.exports=xt;L.exports.default=xt;L.exports.env=e=>{e={env:process.env,...e};let t={...e.env},r=gt({env:t});return e.path=t[r],t[r]=L.exports(e),t}});var vt=a((Ls,fe)=>{"use strict";var wt=(e,t)=>{for(let r of Reflect.ownKeys(t))Object.defineProperty(e,r,Object.getOwnPropertyDescriptor(t,r));return e};fe.exports=wt;fe.exports.default=wt});var It=a(($s,H)=>{"use strict";var Yn=vt(),X=new WeakMap,Et=(e,t={})=>{if(typeof e!="function")throw new TypeError("Expected a function");let r,n=0,s=e.displayName||e.name||"<anonymous>",i=function(...o){if(X.set(i,++n),n===1)r=e.apply(this,o),e=null;else if(t.throw===!0)throw new Error(`Function \`${s}\` can only be called once`);return r};return Yn(i,e),X.set(i,n),i};H.exports=Et;H.exports.default=Et;H.exports.callCount=e=>{if(!X.has(e))throw new Error(`The given function \`${e.name}\` is not wrapped by the \`onetime\` package`);return X.get(e)}});var Tt=a(K=>{"use strict";Object.defineProperty(K,"__esModule",{value:!0});K.SIGNALS=void 0;var Qn=[{name:"SIGHUP",number:1,action:"terminate",description:"Terminal closed",standard:"posix"},{name:"SIGINT",number:2,action:"terminate",description:"User interruption with CTRL-C",standard:"ansi"},{name:"SIGQUIT",number:3,action:"core",description:"User interruption with CTRL-\\",standard:"posix"},{name:"SIGILL",number:4,action:"core",description:"Invalid machine instruction",standard:"ansi"},{name:"SIGTRAP",number:5,action:"core",description:"Debugger breakpoint",standard:"posix"},{name:"SIGABRT",number:6,action:"core",description:"Aborted",standard:"ansi"},{name:"SIGIOT",number:6,action:"core",description:"Aborted",standard:"bsd"},{name:"SIGBUS",number:7,action:"core",description:"Bus error due to misaligned, non-existing address or paging error",standard:"bsd"},{name:"SIGEMT",number:7,action:"terminate",description:"Command should be emulated but is not implemented",standard:"other"},{name:"SIGFPE",number:8,action:"core",description:"Floating point arithmetic error",standard:"ansi"},{name:"SIGKILL",number:9,action:"terminate",description:"Forced termination",standard:"posix",forced:!0},{name:"SIGUSR1",number:10,action:"terminate",description:"Application-specific signal",standard:"posix"},{name:"SIGSEGV",number:11,action:"core",description:"Segmentation fault",standard:"ansi"},{name:"SIGUSR2",number:12,action:"terminate",description:"Application-specific signal",standard:"posix"},{name:"SIGPIPE",number:13,action:"terminate",description:"Broken pipe or socket",standard:"posix"},{name:"SIGALRM",number:14,action:"terminate",description:"Timeout or timer",standard:"posix"},{name:"SIGTERM",number:15,action:"terminate",description:"Termination",standard:"ansi"},{name:"SIGSTKFLT",number:16,action:"terminate",description:"Stack is empty or overflowed",standard:"other"},{name:"SIGCHLD",number:17,action:"ignore",description:"Child process terminated, paused or unpaused",standard:"posix"},{name:"SIGCLD",number:17,action:"ignore",description:"Child process terminated, paused or unpaused",standard:"other"},{name:"SIGCONT",number:18,action:"unpause",description:"Unpaused",standard:"posix",forced:!0},{name:"SIGSTOP",number:19,action:"pause",description:"Paused",standard:"posix",forced:!0},{name:"SIGTSTP",number:20,action:"pause",description:'Paused using CTRL-Z or "suspend"',standard:"posix"},{name:"SIGTTIN",number:21,action:"pause",description:"Background process cannot read terminal input",standard:"posix"},{name:"SIGBREAK",number:21,action:"terminate",description:"User interruption with CTRL-BREAK",standard:"other"},{name:"SIGTTOU",number:22,action:"pause",description:"Background process cannot write to terminal output",standard:"posix"},{name:"SIGURG",number:23,action:"ignore",description:"Socket received out-of-band data",standard:"bsd"},{name:"SIGXCPU",number:24,action:"core",description:"Process timed out",standard:"bsd"},{name:"SIGXFSZ",number:25,action:"core",description:"File too big",standard:"bsd"},{name:"SIGVTALRM",number:26,action:"terminate",description:"Timeout or timer",standard:"bsd"},{name:"SIGPROF",number:27,action:"terminate",description:"Timeout or timer",standard:"bsd"},{name:"SIGWINCH",number:28,action:"ignore",description:"Terminal window size changed",standard:"bsd"},{name:"SIGIO",number:29,action:"terminate",description:"I/O is available",standard:"other"},{name:"SIGPOLL",number:29,action:"terminate",description:"Watched event",standard:"other"},{name:"SIGINFO",number:29,action:"ignore",description:"Request for process information",standard:"other"},{name:"SIGPWR",number:30,action:"terminate",description:"Device running out of power",standard:"systemv"},{name:"SIGSYS",number:31,action:"core",description:"Invalid system call",standard:"other"},{name:"SIGUNUSED",number:31,action:"terminate",description:"Invalid system call",standard:"other"}];K.SIGNALS=Qn});var pe=a(P=>{"use strict";Object.defineProperty(P,"__esModule",{value:!0});P.SIGRTMAX=P.getRealtimeSignals=void 0;var Zn=function(){let e=Pt-Ct+1;return Array.from({length:e},Jn)};P.getRealtimeSignals=Zn;var Jn=function(e,t){return{name:`SIGRT${t+1}`,number:Ct+t,action:"terminate",description:"Application-specific signal (realtime)",standard:"posix"}},Ct=34,Pt=64;P.SIGRTMAX=Pt});var Gt=a(V=>{"use strict";Object.defineProperty(V,"__esModule",{value:!0});V.getSignals=void 0;var er=require("os"),tr=Tt(),nr=pe(),rr=function(){let e=(0,nr.getRealtimeSignals)();return[...tr.SIGNALS,...e].map(sr)};V.getSignals=rr;var sr=function({name:e,number:t,description:r,action:n,forced:s=!1,standard:i}){let{signals:{[e]:o}}=er.constants,c=o!==void 0;return{name:e,number:c?o:t,description:r,supported:c,action:n,forced:s,standard:i}}});var Nt=a(G=>{"use strict";Object.defineProperty(G,"__esModule",{value:!0});G.signalsByNumber=G.signalsByName=void 0;var or=require("os"),At=Gt(),ir=pe(),cr=function(){return(0,At.getSignals)().reduce(ar,{})},ar=function(e,{name:t,number:r,description:n,supported:s,action:i,forced:o,standard:c}){return{...e,[t]:{name:t,number:r,description:n,supported:s,action:i,forced:o,standard:c}}},ur=cr();G.signalsByName=ur;var lr=function(){let e=(0,At.getSignals)(),t=ir.SIGRTMAX+1,r=Array.from({length:t},(n,s)=>dr(s,e));return Object.assign({},...r)},dr=function(e,t){let r=fr(e,t);if(r===void 0)return{};let{name:n,description:s,supported:i,action:o,forced:c,standard:l}=r;return{[e]:{name:n,number:e,description:s,supported:i,action:o,forced:c,standard:l}}},fr=function(e,t){let r=t.find(({name:n})=>or.constants.signals[n]===e);return r!==void 0?r:t.find(n=>n.number===e)},pr=lr();G.signalsByNumber=pr});var Ot=a((Fs,Rt)=>{"use strict";var{signalsByName:mr}=Nt(),hr=({timedOut:e,timeout:t,errorCode:r,signal:n,signalDescription:s,exitCode:i,isCanceled:o})=>e?`timed out after ${t} milliseconds`:o?"was canceled":r!==void 0?`failed with ${r}`:n!==void 0?`was killed with ${n} (${s})`:i!==void 0?`failed with exit code ${i}`:"failed",yr=({stdout:e,stderr:t,all:r,error:n,signal:s,exitCode:i,command:o,escapedCommand:c,timedOut:l,isCanceled:d,killed:p,parsed:{options:{timeout:y}}})=>{i=i===null?void 0:i,s=s===null?void 0:s;let h=s===void 0?void 0:mr[s].description,S=n&&n.code,x=`Command ${hr({timedOut:l,timeout:y,errorCode:S,signal:s,signalDescription:h,exitCode:i,isCanceled:d})}: ${o}`,I=Object.prototype.toString.call(n)==="[object Error]",j=I?`${x}
${n.message}`:x,F=[j,t,e].filter(Boolean).join(`
`);return I?(n.originalMessage=n.message,n.message=F):n=new Error(F),n.shortMessage=j,n.command=o,n.escapedCommand=c,n.exitCode=i,n.signal=s,n.signalDescription=h,n.stdout=e,n.stderr=t,r!==void 0&&(n.all=r),"bufferedData"in n&&delete n.bufferedData,n.failed=!0,n.timedOut=!!l,n.isCanceled=d,n.killed=p&&!l,n};Rt.exports=yr});var kt=a((Ds,me)=>{"use strict";var W=["stdin","stdout","stderr"],Sr=e=>W.some(t=>e[t]!==void 0),qt=e=>{if(!e)return;let{stdio:t}=e;if(t===void 0)return W.map(n=>e[n]);if(Sr(e))throw new Error(`It's not possible to provide \`stdio\` in combination with one of ${W.map(n=>`\`${n}\``).join(", ")}`);if(typeof t=="string")return t;if(!Array.isArray(t))throw new TypeError(`Expected \`stdio\` to be of type \`string\` or \`Array\`, got \`${typeof t}\``);let r=Math.max(t.length,W.length);return Array.from({length:r},(n,s)=>t[s])};me.exports=qt;me.exports.node=e=>{let t=qt(e);return t==="ipc"?"ipc":t===void 0||typeof t=="string"?[t,t,t,"ipc"]:t.includes("ipc")?t:[...t,"ipc"]}});var Lt=a((Us,z)=>{z.exports=["SIGABRT","SIGALRM","SIGHUP","SIGINT","SIGTERM"];process.platform!=="win32"&&z.exports.push("SIGVTALRM","SIGXCPU","SIGXFSZ","SIGUSR2","SIGTRAP","SIGSYS","SIGQUIT","SIGIOT");process.platform==="linux"&&z.exports.push("SIGIO","SIGPOLL","SIGPWR","SIGSTKFLT","SIGUNUSED")});var jt=a((Xs,R)=>{var f=global.process,w=function(e){return e&&typeof e=="object"&&typeof e.removeListener=="function"&&typeof e.emit=="function"&&typeof e.reallyExit=="function"&&typeof e.listeners=="function"&&typeof e.kill=="function"&&typeof e.pid=="number"&&typeof e.on=="function"};w(f)?($t=require("assert"),A=Lt(),_t=/^win/i.test(f.platform),$=require("events"),typeof $!="function"&&($=$.EventEmitter),f.__signal_exit_emitter__?m=f.__signal_exit_emitter__:(m=f.__signal_exit_emitter__=new $,m.count=0,m.emitted={}),m.infinite||(m.setMaxListeners(1/0),m.infinite=!0),R.exports=function(e,t){if(w(global.process)){$t.equal(typeof e,"function","a callback must be provided for exit handler"),N===!1&&he();var r="exit";t&&t.alwaysLast&&(r="afterexit");var n=function(){m.removeListener(r,e),m.listeners("exit").length===0&&m.listeners("afterexit").length===0&&Y()};return m.on(r,e),n}},Y=function(){!N||!w(global.process)||(N=!1,A.forEach(function(t){try{f.removeListener(t,Q[t])}catch{}}),f.emit=Z,f.reallyExit=ye,m.count-=1)},R.exports.unload=Y,v=function(t,r,n){m.emitted[t]||(m.emitted[t]=!0,m.emit(t,r,n))},Q={},A.forEach(function(e){Q[e]=function(){if(w(global.process)){var r=f.listeners(e);r.length===m.count&&(Y(),v("exit",null,e),v("afterexit",null,e),_t&&e==="SIGHUP"&&(e="SIGINT"),f.kill(f.pid,e))}}}),R.exports.signals=function(){return A},N=!1,he=function(){N||!w(global.process)||(N=!0,m.count+=1,A=A.filter(function(t){try{return f.on(t,Q[t]),!0}catch{return!1}}),f.emit=Mt,f.reallyExit=Bt)},R.exports.load=he,ye=f.reallyExit,Bt=function(t){w(global.process)&&(f.exitCode=t||0,v("exit",f.exitCode,null),v("afterexit",f.exitCode,null),ye.call(f,f.exitCode))},Z=f.emit,Mt=function(t,r){if(t==="exit"&&w(global.process)){r!==void 0&&(f.exitCode=r);var n=Z.apply(this,arguments);return v("exit",f.exitCode,null),v("afterexit",f.exitCode,null),n}else return Z.apply(this,arguments)}):R.exports=function(){};var $t,A,_t,$,m,Y,v,Q,N,he,ye,Bt,Z,Mt});var Dt=a((Hs,Ft)=>{"use strict";var gr=require("os"),xr=jt(),br=1e3*5,wr=(e,t="SIGTERM",r={})=>{let n=e(t);return vr(e,t,r,n),n},vr=(e,t,r,n)=>{if(!Er(t,r,n))return;let s=Tr(r),i=setTimeout(()=>{e("SIGKILL")},s);i.unref&&i.unref()},Er=(e,{forceKillAfterTimeout:t},r)=>Ir(e)&&t!==!1&&r,Ir=e=>e===gr.constants.signals.SIGTERM||typeof e=="string"&&e.toUpperCase()==="SIGTERM",Tr=({forceKillAfterTimeout:e=!0})=>{if(e===!0)return br;if(!Number.isFinite(e)||e<0)throw new TypeError(`Expected the \`forceKillAfterTimeout\` option to be a non-negative integer, got \`${e}\` (${typeof e})`);return e},Cr=(e,t)=>{e.kill()&&(t.isCanceled=!0)},Pr=(e,t,r)=>{e.kill(t),r(Object.assign(new Error("Timed out"),{timedOut:!0,signal:t}))},Gr=(e,{timeout:t,killSignal:r="SIGTERM"},n)=>{if(t===0||t===void 0)return n;let s,i=new Promise((c,l)=>{s=setTimeout(()=>{Pr(e,r,l)},t)}),o=n.finally(()=>{clearTimeout(s)});return Promise.race([i,o])},Ar=({timeout:e})=>{if(e!==void 0&&(!Number.isFinite(e)||e<0))throw new TypeError(`Expected the \`timeout\` option to be a non-negative integer, got \`${e}\` (${typeof e})`)},Nr=async(e,{cleanup:t,detached:r},n)=>{if(!t||r)return n;let s=xr(()=>{e.kill()});return n.finally(()=>{s()})};Ft.exports={spawnedKill:wr,spawnedCancel:Cr,setupTimeout:Gr,validateTimeout:Ar,setExitHandler:Nr}});var Xt=a((Ks,Ut)=>{"use strict";var b=e=>e!==null&&typeof e=="object"&&typeof e.pipe=="function";b.writable=e=>b(e)&&e.writable!==!1&&typeof e._write=="function"&&typeof e._writableState=="object";b.readable=e=>b(e)&&e.readable!==!1&&typeof e._read=="function"&&typeof e._readableState=="object";b.duplex=e=>b.writable(e)&&b.readable(e);b.transform=e=>b.duplex(e)&&typeof e._transform=="function";Ut.exports=b});var Kt=a((Vs,Ht)=>{"use strict";var{PassThrough:Rr}=require("stream");Ht.exports=e=>{e={...e};let{array:t}=e,{encoding:r}=e,n=r==="buffer",s=!1;t?s=!(r||n):r=r||"utf8",n&&(r=null);let i=new Rr({objectMode:s});r&&i.setEncoding(r);let o=0,c=[];return i.on("data",l=>{c.push(l),s?o=c.length:o+=l.length}),i.getBufferedValue=()=>t?c:n?Buffer.concat(c,o):c.join(""),i.getBufferedLength=()=>o,i}});var Vt=a((Ws,_)=>{"use strict";var{constants:Or}=require("buffer"),qr=require("stream"),{promisify:kr}=require("util"),Lr=Kt(),$r=kr(qr.pipeline),J=class extends Error{constructor(){super("maxBuffer exceeded"),this.name="MaxBufferError"}};async function Se(e,t){if(!e)throw new Error("Expected a stream");t={maxBuffer:1/0,...t};let{maxBuffer:r}=t,n=Lr(t);return await new Promise((s,i)=>{let o=c=>{c&&n.getBufferedLength()<=Or.MAX_LENGTH&&(c.bufferedData=n.getBufferedValue()),i(c)};(async()=>{try{await $r(e,n),s()}catch(c){o(c)}})(),n.on("data",()=>{n.getBufferedLength()>r&&o(new J)})}),n.getBufferedValue()}_.exports=Se;_.exports.buffer=(e,t)=>Se(e,{...t,encoding:"buffer"});_.exports.array=(e,t)=>Se(e,{...t,array:!0});_.exports.MaxBufferError=J});var zt=a((zs,Wt)=>{"use strict";var{PassThrough:_r}=require("stream");Wt.exports=function(){var e=[],t=new _r({objectMode:!0});return t.setMaxListeners(0),t.add=r,t.isEmpty=n,t.on("unpipe",s),Array.prototype.slice.call(arguments).forEach(r),t;function r(i){return Array.isArray(i)?(i.forEach(r),this):(e.push(i),i.once("end",s.bind(null,i)),i.once("error",t.emit.bind(t,"error")),i.pipe(t,{end:!1}),this)}function n(){return e.length==0}function s(i){e=e.filter(function(o){return o!==i}),!e.length&&t.readable&&t.end()}}});var Jt=a((Ys,Zt)=>{"use strict";var Qt=Xt(),Yt=Vt(),Br=zt(),Mr=(e,t)=>{t===void 0||e.stdin===void 0||(Qt(t)?t.pipe(e.stdin):e.stdin.end(t))},jr=(e,{all:t})=>{if(!t||!e.stdout&&!e.stderr)return;let r=Br();return e.stdout&&r.add(e.stdout),e.stderr&&r.add(e.stderr),r},ge=async(e,t)=>{if(e){e.destroy();try{return await t}catch(r){return r.bufferedData}}},xe=(e,{encoding:t,buffer:r,maxBuffer:n})=>{if(!(!e||!r))return t?Yt(e,{encoding:t,maxBuffer:n}):Yt.buffer(e,{maxBuffer:n})},Fr=async({stdout:e,stderr:t,all:r},{encoding:n,buffer:s,maxBuffer:i},o)=>{let c=xe(e,{encoding:n,buffer:s,maxBuffer:i}),l=xe(t,{encoding:n,buffer:s,maxBuffer:i}),d=xe(r,{encoding:n,buffer:s,maxBuffer:i*2});try{return await Promise.all([o,c,l,d])}catch(p){return Promise.all([{error:p,signal:p.signal,timedOut:p.timedOut},ge(e,c),ge(t,l),ge(r,d)])}},Dr=({input:e})=>{if(Qt(e))throw new TypeError("The `input` option cannot be a stream in sync mode")};Zt.exports={handleInput:Mr,makeAllStream:jr,getSpawnedResult:Fr,validateInputSync:Dr}});var tn=a((Qs,en)=>{"use strict";var Ur=(async()=>{})().constructor.prototype,Xr=["then","catch","finally"].map(e=>[e,Reflect.getOwnPropertyDescriptor(Ur,e)]),Hr=(e,t)=>{for(let[r,n]of Xr){let s=typeof t=="function"?(...i)=>Reflect.apply(n.value,t(),i):n.value.bind(t);Reflect.defineProperty(e,r,{...n,value:s})}return e},Kr=e=>new Promise((t,r)=>{e.on("exit",(n,s)=>{t({exitCode:n,signal:s})}),e.on("error",n=>{r(n)}),e.stdin&&e.stdin.on("error",n=>{r(n)})});en.exports={mergePromise:Hr,getSpawnedPromise:Kr}});var sn=a((Zs,rn)=>{"use strict";var nn=(e,t=[])=>Array.isArray(t)?[e,...t]:[e],Vr=/^[\w.-]+$/,Wr=/"/g,zr=e=>typeof e!="string"||Vr.test(e)?e:`"${e.replace(Wr,'\\"')}"`,Yr=(e,t)=>nn(e,t).join(" "),Qr=(e,t)=>nn(e,t).map(r=>zr(r)).join(" "),Zr=/ +/g,Jr=e=>{let t=[];for(let r of e.trim().split(Zr)){let n=t[t.length-1];n&&n.endsWith("\\")?t[t.length-1]=`${n.slice(0,-1)} ${r}`:t.push(r)}return t};rn.exports={joinCommand:Yr,getEscapedCommand:Qr,parseCommand:Jr}});var fn=a((Js,O)=>{"use strict";var es=require("path"),be=require("child_process"),ts=ht(),ns=St(),rs=bt(),ss=It(),ee=Ot(),cn=kt(),{spawnedKill:os,spawnedCancel:is,setupTimeout:cs,validateTimeout:as,setExitHandler:us}=Dt(),{handleInput:ls,getSpawnedResult:ds,makeAllStream:fs,validateInputSync:ps}=Jt(),{mergePromise:on,getSpawnedPromise:ms}=tn(),{joinCommand:an,parseCommand:un,getEscapedCommand:ln}=sn(),hs=1e3*1e3*100,ys=({env:e,extendEnv:t,preferLocal:r,localDir:n,execPath:s})=>{let i=t?{...process.env,...e}:e;return r?rs.env({env:i,cwd:n,execPath:s}):i},dn=(e,t,r={})=>{let n=ts._parse(e,t,r);return e=n.command,t=n.args,r=n.options,r={maxBuffer:hs,buffer:!0,stripFinalNewline:!0,extendEnv:!0,preferLocal:!1,localDir:r.cwd||process.cwd(),execPath:process.execPath,encoding:"utf8",reject:!0,cleanup:!0,all:!1,windowsHide:!0,...r},r.env=ys(r),r.stdio=cn(r),process.platform==="win32"&&es.basename(e,".exe")==="cmd"&&t.unshift("/q"),{file:e,args:t,options:r,parsed:n}},B=(e,t,r)=>typeof t!="string"&&!Buffer.isBuffer(t)?r===void 0?void 0:"":e.stripFinalNewline?ns(t):t,te=(e,t,r)=>{let n=dn(e,t,r),s=an(e,t),i=ln(e,t);as(n.options);let o;try{o=be.spawn(n.file,n.args,n.options)}catch(S){let g=new be.ChildProcess,x=Promise.reject(ee({error:S,stdout:"",stderr:"",all:"",command:s,escapedCommand:i,parsed:n,timedOut:!1,isCanceled:!1,killed:!1}));return on(g,x)}let c=ms(o),l=cs(o,n.options,c),d=us(o,n.options,l),p={isCanceled:!1};o.kill=os.bind(null,o.kill.bind(o)),o.cancel=is.bind(null,o,p);let h=ss(async()=>{let[{error:S,exitCode:g,signal:x,timedOut:I},j,F,yn]=await ds(o,n.options,d),Ee=B(n.options,j),Ie=B(n.options,F),Te=B(n.options,yn);if(S||g!==0||x!==null){let Ce=ee({error:S,exitCode:g,signal:x,stdout:Ee,stderr:Ie,all:Te,command:s,escapedCommand:i,parsed:n,timedOut:I,isCanceled:p.isCanceled,killed:o.killed});if(!n.options.reject)return Ce;throw Ce}return{command:s,escapedCommand:i,exitCode:0,stdout:Ee,stderr:Ie,all:Te,failed:!1,timedOut:!1,isCanceled:!1,killed:!1}});return ls(o,n.options.input),o.all=fs(o,n.options),on(o,h)};O.exports=te;O.exports.sync=(e,t,r)=>{let n=dn(e,t,r),s=an(e,t),i=ln(e,t);ps(n.options);let o;try{o=be.spawnSync(n.file,n.args,n.options)}catch(d){throw ee({error:d,stdout:"",stderr:"",all:"",command:s,escapedCommand:i,parsed:n,timedOut:!1,isCanceled:!1,killed:!1})}let c=B(n.options,o.stdout,o.error),l=B(n.options,o.stderr,o.error);if(o.error||o.status!==0||o.signal!==null){let d=ee({stdout:c,stderr:l,error:o.error,signal:o.signal,exitCode:o.status,command:s,escapedCommand:i,parsed:n,timedOut:o.error&&o.error.code==="ETIMEDOUT",isCanceled:!1,killed:o.signal!==null});if(!n.options.reject)return d;throw d}return{command:s,escapedCommand:i,exitCode:0,stdout:c,stderr:l,failed:!1,timedOut:!1,isCanceled:!1,killed:!1}};O.exports.command=(e,t)=>{let[r,...n]=un(e);return te(r,n,t)};O.exports.commandSync=(e,t)=>{let[r,...n]=un(e);return te.sync(r,n,t)};O.exports.node=(e,t,r={})=>{t&&!Array.isArray(t)&&typeof t=="object"&&(r=t,t=[]);let n=cn.node(r),s=process.execArgv.filter(c=>!c.startsWith("--inspect")),{nodePath:i=process.execPath,nodeOptions:o=s}=r;return te(i,[...o,e,...Array.isArray(t)?t:[]],{...r,stdin:void 0,stdout:void 0,stderr:void 0,stdio:n,shell:!1})}});var Ss={};vn(Ss,{default:()=>hn});module.exports=En(Ss);var u=require("@raycast/api"),q=require("react");var we=Ge(require("node:process"),1),ve=Ge(fn(),1);async function pn(e){if(we.default.platform!=="darwin")throw new Error("macOS only");let{stdout:t}=await(0,ve.default)("osascript",["-e",e]);return t}function M(e){if(we.default.platform!=="darwin")throw new Error("macOS only");let{stdout:t}=ve.default.sync("osascript",["-e",e]);return t}var E=require("react/jsx-runtime");async function mn(){try{return(await pn(`
      tell application "Tunnelblick" to get configurations
    `)).split(",").map(r=>{let n=r.replace("configuration ","").trim(),s=M(`
      tell application "Tunnelblick" to get state of first configuration where name = "${n}"
    `);return{name:n,status:s}})}catch{return new Promise((e,t)=>t("Couln't get VPN connections. Make sure you have Tunnelblick installed."))}}function hn(){let[e,t]=(0,q.useState)(!0),[r,n]=(0,q.useState)([]),[s,i]=(0,q.useState)(null);return(0,q.useEffect)(()=>{(0,u.showToast)({style:u.Toast.Style.Animated,title:"Getting configurations"}),mn().then(o=>{n(o)}).catch(o=>{i(new Error(o))}).finally(()=>{u.Toast.prototype.hide(),t(!1)})},[]),s&&(0,u.showToast)({style:u.Toast.Style.Failure,title:"Something went wrong",message:s.message}),(0,E.jsx)(u.List,{isLoading:e,children:r.map(o=>(0,E.jsx)(u.List.Item,{icon:o.status==="EXITING"?u.Icon.Network:{source:u.Icon.Network,tintColor:u.Color.Green},title:o.name,accessories:[{tag:{value:o.status==="EXITING"?"Disconnected":"Connected",color:o.status==="EXITING"?u.Color.Red:u.Color.Green}}],actions:(0,E.jsxs)(u.ActionPanel,{children:[(0,E.jsx)(u.Action,{title:o.status==="EXITING"?"Connect":"Disconnect",icon:o.status==="EXITING"?u.Icon.Livestream:u.Icon.LivestreamDisabled,onAction:()=>{o.status==="EXITING"?(M(`tell application "Tunnelblick" to connect "${o.name}"`),(0,u.showToast)({style:u.Toast.Style.Success,title:"Connected"})):(M(`tell application "Tunnelblick" to disconnect "${o.name}"`),(0,u.showToast)({style:u.Toast.Style.Success,title:"Disconnected"})),mn().then(n)}},o.name),(0,E.jsx)(u.Action,{title:"Disconnect All",icon:u.Icon.LivestreamDisabled,shortcut:{modifiers:["cmd"],key:"delete"},onAction:()=>{M('tell application "Tunnelblick" to disconnect all'),(0,u.showToast)({style:u.Toast.Style.Success,title:"Disconnected"})}},"disconnectAllConnections")]})},o.name))})}
