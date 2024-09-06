"use strict";var Sn=Object.create;var j=Object.defineProperty;var xn=Object.getOwnPropertyDescriptor;var wn=Object.getOwnPropertyNames;var bn=Object.getPrototypeOf,vn=Object.prototype.hasOwnProperty;var a=(e,t)=>()=>(t||e((t={exports:{}}).exports,t),t.exports),In=(e,t)=>{for(var r in t)j(e,r,{get:t[r],enumerable:!0})},Ie=(e,t,r,n)=>{if(t&&typeof t=="object"||typeof t=="function")for(let o of wn(t))!vn.call(e,o)&&o!==r&&j(e,o,{get:()=>t[o],enumerable:!(n=xn(t,o))||n.enumerable});return e};var Ee=(e,t,r)=>(r=e!=null?Sn(bn(e)):{},Ie(t||!e||!e.__esModule?j(r,"default",{value:e,enumerable:!0}):r,e)),En=e=>Ie(j({},"__esModule",{value:!0}),e);var Ge=a((Io,Ae)=>{Ae.exports=Ce;Ce.sync=Tn;var Pe=require("fs");function Pn(e,t){var r=t.pathExt!==void 0?t.pathExt:process.env.PATHEXT;if(!r||(r=r.split(";"),r.indexOf("")!==-1))return!0;for(var n=0;n<r.length;n++){var o=r[n].toLowerCase();if(o&&e.substr(-o.length).toLowerCase()===o)return!0}return!1}function Te(e,t,r){return!e.isSymbolicLink()&&!e.isFile()?!1:Pn(t,r)}function Ce(e,t,r){Pe.stat(e,function(n,o){r(n,n?!1:Te(o,e,t))})}function Tn(e,t){return Te(Pe.statSync(e),e,t)}});var _e=a((Eo,Ne)=>{Ne.exports=Oe;Oe.sync=Cn;var Re=require("fs");function Oe(e,t,r){Re.stat(e,function(n,o){r(n,n?!1:qe(o,t))})}function Cn(e,t){return qe(Re.statSync(e),t)}function qe(e,t){return e.isFile()&&An(e,t)}function An(e,t){var r=e.mode,n=e.uid,o=e.gid,s=t.uid!==void 0?t.uid:process.getuid&&process.getuid(),i=t.gid!==void 0?t.gid:process.getgid&&process.getgid(),c=parseInt("100",8),u=parseInt("010",8),d=parseInt("001",8),f=c|u,h=r&d||r&u&&o===i||r&c&&n===s||r&f&&s===0;return h}});var ke=a((To,$e)=>{var Po=require("fs"),M;process.platform==="win32"||global.TESTING_WINDOWS?M=Ge():M=_e();$e.exports=J;J.sync=Gn;function J(e,t,r){if(typeof t=="function"&&(r=t,t={}),!r){if(typeof Promise!="function")throw new TypeError("callback not provided");return new Promise(function(n,o){J(e,t||{},function(s,i){s?o(s):n(i)})})}M(e,t||{},function(n,o){n&&(n.code==="EACCES"||t&&t.ignoreErrors)&&(n=null,o=!1),r(n,o)})}function Gn(e,t){try{return M.sync(e,t||{})}catch(r){if(t&&t.ignoreErrors||r.code==="EACCES")return!1;throw r}}});var De=a((Co,Fe)=>{var E=process.platform==="win32"||process.env.OSTYPE==="cygwin"||process.env.OSTYPE==="msys",Le=require("path"),Rn=E?";":":",Be=ke(),je=e=>Object.assign(new Error(`not found: ${e}`),{code:"ENOENT"}),Me=(e,t)=>{let r=t.colon||Rn,n=e.match(/\//)||E&&e.match(/\\/)?[""]:[...E?[process.cwd()]:[],...(t.path||process.env.PATH||"").split(r)],o=E?t.pathExt||process.env.PATHEXT||".EXE;.CMD;.BAT;.COM":"",s=E?o.split(r):[""];return E&&e.indexOf(".")!==-1&&s[0]!==""&&s.unshift(""),{pathEnv:n,pathExt:s,pathExtExe:o}},Ue=(e,t,r)=>{typeof t=="function"&&(r=t,t={}),t||(t={});let{pathEnv:n,pathExt:o,pathExtExe:s}=Me(e,t),i=[],c=d=>new Promise((f,h)=>{if(d===n.length)return t.all&&i.length?f(i):h(je(e));let m=n[d],g=/^".*"$/.test(m)?m.slice(1,-1):m,y=Le.join(g,e),S=!g&&/^\.[\\\/]/.test(e)?e.slice(0,2)+y:y;f(u(S,d,0))}),u=(d,f,h)=>new Promise((m,g)=>{if(h===o.length)return m(c(f+1));let y=o[h];Be(d+y,{pathExt:s},(S,I)=>{if(!S&&I)if(t.all)i.push(d+y);else return m(d+y);return m(u(d,f,h+1))})});return r?c(0).then(d=>r(null,d),r):c(0)},On=(e,t)=>{t=t||{};let{pathEnv:r,pathExt:n,pathExtExe:o}=Me(e,t),s=[];for(let i=0;i<r.length;i++){let c=r[i],u=/^".*"$/.test(c)?c.slice(1,-1):c,d=Le.join(u,e),f=!u&&/^\.[\\\/]/.test(e)?e.slice(0,2)+d:d;for(let h=0;h<n.length;h++){let m=f+n[h];try{if(Be.sync(m,{pathExt:o}))if(t.all)s.push(m);else return m}catch{}}}if(t.all&&s.length)return s;if(t.nothrow)return null;throw je(e)};Fe.exports=Ue;Ue.sync=On});var te=a((Ao,ee)=>{"use strict";var He=(e={})=>{let t=e.env||process.env;return(e.platform||process.platform)!=="win32"?"PATH":Object.keys(t).reverse().find(n=>n.toUpperCase()==="PATH")||"Path"};ee.exports=He;ee.exports.default=He});var ze=a((Go,We)=>{"use strict";var Xe=require("path"),qn=De(),Nn=te();function Ke(e,t){let r=e.options.env||process.env,n=process.cwd(),o=e.options.cwd!=null,s=o&&process.chdir!==void 0&&!process.chdir.disabled;if(s)try{process.chdir(e.options.cwd)}catch{}let i;try{i=qn.sync(e.command,{path:r[Nn({env:r})],pathExt:t?Xe.delimiter:void 0})}catch{}finally{s&&process.chdir(n)}return i&&(i=Xe.resolve(o?e.options.cwd:"",i)),i}function _n(e){return Ke(e)||Ke(e,!0)}We.exports=_n});var Ve=a((Ro,re)=>{"use strict";var ne=/([()\][%!^"`<>&|;, *?])/g;function $n(e){return e=e.replace(ne,"^$1"),e}function kn(e,t){return e=`${e}`,e=e.replace(/(\\*)"/g,'$1$1\\"'),e=e.replace(/(\\*)$/,"$1$1"),e=`"${e}"`,e=e.replace(ne,"^$1"),t&&(e=e.replace(ne,"^$1")),e}re.exports.command=$n;re.exports.argument=kn});var Qe=a((Oo,Ye)=>{"use strict";Ye.exports=/^#!(.*)/});var Je=a((qo,Ze)=>{"use strict";var Ln=Qe();Ze.exports=(e="")=>{let t=e.match(Ln);if(!t)return null;let[r,n]=t[0].replace(/#! ?/,"").split(" "),o=r.split("/").pop();return o==="env"?n:n?`${o} ${n}`:o}});var tt=a((No,et)=>{"use strict";var oe=require("fs"),Bn=Je();function jn(e){let r=Buffer.alloc(150),n;try{n=oe.openSync(e,"r"),oe.readSync(n,r,0,150,0),oe.closeSync(n)}catch{}return Bn(r.toString())}et.exports=jn});var st=a((_o,ot)=>{"use strict";var Mn=require("path"),nt=ze(),rt=Ve(),Un=tt(),Fn=process.platform==="win32",Dn=/\.(?:com|exe)$/i,Hn=/node_modules[\\/].bin[\\/][^\\/]+\.cmd$/i;function Xn(e){e.file=nt(e);let t=e.file&&Un(e.file);return t?(e.args.unshift(e.file),e.command=t,nt(e)):e.file}function Kn(e){if(!Fn)return e;let t=Xn(e),r=!Dn.test(t);if(e.options.forceShell||r){let n=Hn.test(t);e.command=Mn.normalize(e.command),e.command=rt.command(e.command),e.args=e.args.map(s=>rt.argument(s,n));let o=[e.command].concat(e.args).join(" ");e.args=["/d","/s","/c",`"${o}"`],e.command=process.env.comspec||"cmd.exe",e.options.windowsVerbatimArguments=!0}return e}function Wn(e,t,r){t&&!Array.isArray(t)&&(r=t,t=null),t=t?t.slice(0):[],r=Object.assign({},r);let n={command:e,args:t,options:r,file:void 0,original:{command:e,args:t}};return r.shell?n:Kn(n)}ot.exports=Wn});var at=a(($o,ct)=>{"use strict";var se=process.platform==="win32";function ie(e,t){return Object.assign(new Error(`${t} ${e.command} ENOENT`),{code:"ENOENT",errno:"ENOENT",syscall:`${t} ${e.command}`,path:e.command,spawnargs:e.args})}function zn(e,t){if(!se)return;let r=e.emit;e.emit=function(n,o){if(n==="exit"){let s=it(o,t,"spawn");if(s)return r.call(e,"error",s)}return r.apply(e,arguments)}}function it(e,t){return se&&e===1&&!t.file?ie(t.original,"spawn"):null}function Vn(e,t){return se&&e===1&&!t.file?ie(t.original,"spawnSync"):null}ct.exports={hookChildProcess:zn,verifyENOENT:it,verifyENOENTSync:Vn,notFoundError:ie}});var lt=a((ko,P)=>{"use strict";var ut=require("child_process"),ce=st(),ae=at();function dt(e,t,r){let n=ce(e,t,r),o=ut.spawn(n.command,n.args,n.options);return ae.hookChildProcess(o,n),o}function Yn(e,t,r){let n=ce(e,t,r),o=ut.spawnSync(n.command,n.args,n.options);return o.error=o.error||ae.verifyENOENTSync(o.status,n),o}P.exports=dt;P.exports.spawn=dt;P.exports.sync=Yn;P.exports._parse=ce;P.exports._enoent=ae});var pt=a((Lo,ft)=>{"use strict";ft.exports=e=>{let t=typeof e=="string"?`
`:`
`.charCodeAt(),r=typeof e=="string"?"\r":"\r".charCodeAt();return e[e.length-1]===t&&(e=e.slice(0,e.length-1)),e[e.length-1]===r&&(e=e.slice(0,e.length-1)),e}});var gt=a((Bo,N)=>{"use strict";var q=require("path"),mt=te(),ht=e=>{e={cwd:process.cwd(),path:process.env[mt()],execPath:process.execPath,...e};let t,r=q.resolve(e.cwd),n=[];for(;t!==r;)n.push(q.join(r,"node_modules/.bin")),t=r,r=q.resolve(r,"..");let o=q.resolve(e.cwd,e.execPath,"..");return n.push(o),n.concat(e.path).join(q.delimiter)};N.exports=ht;N.exports.default=ht;N.exports.env=e=>{e={env:process.env,...e};let t={...e.env},r=mt({env:t});return e.path=t[r],t[r]=N.exports(e),t}});var St=a((jo,ue)=>{"use strict";var yt=(e,t)=>{for(let r of Reflect.ownKeys(t))Object.defineProperty(e,r,Object.getOwnPropertyDescriptor(t,r));return e};ue.exports=yt;ue.exports.default=yt});var wt=a((Mo,F)=>{"use strict";var Qn=St(),U=new WeakMap,xt=(e,t={})=>{if(typeof e!="function")throw new TypeError("Expected a function");let r,n=0,o=e.displayName||e.name||"<anonymous>",s=function(...i){if(U.set(s,++n),n===1)r=e.apply(this,i),e=null;else if(t.throw===!0)throw new Error(`Function \`${o}\` can only be called once`);return r};return Qn(s,e),U.set(s,n),s};F.exports=xt;F.exports.default=xt;F.exports.callCount=e=>{if(!U.has(e))throw new Error(`The given function \`${e.name}\` is not wrapped by the \`onetime\` package`);return U.get(e)}});var bt=a(D=>{"use strict";Object.defineProperty(D,"__esModule",{value:!0});D.SIGNALS=void 0;var Zn=[{name:"SIGHUP",number:1,action:"terminate",description:"Terminal closed",standard:"posix"},{name:"SIGINT",number:2,action:"terminate",description:"User interruption with CTRL-C",standard:"ansi"},{name:"SIGQUIT",number:3,action:"core",description:"User interruption with CTRL-\\",standard:"posix"},{name:"SIGILL",number:4,action:"core",description:"Invalid machine instruction",standard:"ansi"},{name:"SIGTRAP",number:5,action:"core",description:"Debugger breakpoint",standard:"posix"},{name:"SIGABRT",number:6,action:"core",description:"Aborted",standard:"ansi"},{name:"SIGIOT",number:6,action:"core",description:"Aborted",standard:"bsd"},{name:"SIGBUS",number:7,action:"core",description:"Bus error due to misaligned, non-existing address or paging error",standard:"bsd"},{name:"SIGEMT",number:7,action:"terminate",description:"Command should be emulated but is not implemented",standard:"other"},{name:"SIGFPE",number:8,action:"core",description:"Floating point arithmetic error",standard:"ansi"},{name:"SIGKILL",number:9,action:"terminate",description:"Forced termination",standard:"posix",forced:!0},{name:"SIGUSR1",number:10,action:"terminate",description:"Application-specific signal",standard:"posix"},{name:"SIGSEGV",number:11,action:"core",description:"Segmentation fault",standard:"ansi"},{name:"SIGUSR2",number:12,action:"terminate",description:"Application-specific signal",standard:"posix"},{name:"SIGPIPE",number:13,action:"terminate",description:"Broken pipe or socket",standard:"posix"},{name:"SIGALRM",number:14,action:"terminate",description:"Timeout or timer",standard:"posix"},{name:"SIGTERM",number:15,action:"terminate",description:"Termination",standard:"ansi"},{name:"SIGSTKFLT",number:16,action:"terminate",description:"Stack is empty or overflowed",standard:"other"},{name:"SIGCHLD",number:17,action:"ignore",description:"Child process terminated, paused or unpaused",standard:"posix"},{name:"SIGCLD",number:17,action:"ignore",description:"Child process terminated, paused or unpaused",standard:"other"},{name:"SIGCONT",number:18,action:"unpause",description:"Unpaused",standard:"posix",forced:!0},{name:"SIGSTOP",number:19,action:"pause",description:"Paused",standard:"posix",forced:!0},{name:"SIGTSTP",number:20,action:"pause",description:'Paused using CTRL-Z or "suspend"',standard:"posix"},{name:"SIGTTIN",number:21,action:"pause",description:"Background process cannot read terminal input",standard:"posix"},{name:"SIGBREAK",number:21,action:"terminate",description:"User interruption with CTRL-BREAK",standard:"other"},{name:"SIGTTOU",number:22,action:"pause",description:"Background process cannot write to terminal output",standard:"posix"},{name:"SIGURG",number:23,action:"ignore",description:"Socket received out-of-band data",standard:"bsd"},{name:"SIGXCPU",number:24,action:"core",description:"Process timed out",standard:"bsd"},{name:"SIGXFSZ",number:25,action:"core",description:"File too big",standard:"bsd"},{name:"SIGVTALRM",number:26,action:"terminate",description:"Timeout or timer",standard:"bsd"},{name:"SIGPROF",number:27,action:"terminate",description:"Timeout or timer",standard:"bsd"},{name:"SIGWINCH",number:28,action:"ignore",description:"Terminal window size changed",standard:"bsd"},{name:"SIGIO",number:29,action:"terminate",description:"I/O is available",standard:"other"},{name:"SIGPOLL",number:29,action:"terminate",description:"Watched event",standard:"other"},{name:"SIGINFO",number:29,action:"ignore",description:"Request for process information",standard:"other"},{name:"SIGPWR",number:30,action:"terminate",description:"Device running out of power",standard:"systemv"},{name:"SIGSYS",number:31,action:"core",description:"Invalid system call",standard:"other"},{name:"SIGUNUSED",number:31,action:"terminate",description:"Invalid system call",standard:"other"}];D.SIGNALS=Zn});var de=a(T=>{"use strict";Object.defineProperty(T,"__esModule",{value:!0});T.SIGRTMAX=T.getRealtimeSignals=void 0;var Jn=function(){let e=It-vt+1;return Array.from({length:e},er)};T.getRealtimeSignals=Jn;var er=function(e,t){return{name:`SIGRT${t+1}`,number:vt+t,action:"terminate",description:"Application-specific signal (realtime)",standard:"posix"}},vt=34,It=64;T.SIGRTMAX=It});var Et=a(H=>{"use strict";Object.defineProperty(H,"__esModule",{value:!0});H.getSignals=void 0;var tr=require("os"),nr=bt(),rr=de(),or=function(){let e=(0,rr.getRealtimeSignals)();return[...nr.SIGNALS,...e].map(sr)};H.getSignals=or;var sr=function({name:e,number:t,description:r,action:n,forced:o=!1,standard:s}){let{signals:{[e]:i}}=tr.constants,c=i!==void 0;return{name:e,number:c?i:t,description:r,supported:c,action:n,forced:o,standard:s}}});var Tt=a(C=>{"use strict";Object.defineProperty(C,"__esModule",{value:!0});C.signalsByNumber=C.signalsByName=void 0;var ir=require("os"),Pt=Et(),cr=de(),ar=function(){return(0,Pt.getSignals)().reduce(ur,{})},ur=function(e,{name:t,number:r,description:n,supported:o,action:s,forced:i,standard:c}){return{...e,[t]:{name:t,number:r,description:n,supported:o,action:s,forced:i,standard:c}}},dr=ar();C.signalsByName=dr;var lr=function(){let e=(0,Pt.getSignals)(),t=cr.SIGRTMAX+1,r=Array.from({length:t},(n,o)=>fr(o,e));return Object.assign({},...r)},fr=function(e,t){let r=pr(e,t);if(r===void 0)return{};let{name:n,description:o,supported:s,action:i,forced:c,standard:u}=r;return{[e]:{name:n,number:e,description:o,supported:s,action:i,forced:c,standard:u}}},pr=function(e,t){let r=t.find(({name:n})=>ir.constants.signals[n]===e);return r!==void 0?r:t.find(n=>n.number===e)},mr=lr();C.signalsByNumber=mr});var At=a((Xo,Ct)=>{"use strict";var{signalsByName:hr}=Tt(),gr=({timedOut:e,timeout:t,errorCode:r,signal:n,signalDescription:o,exitCode:s,isCanceled:i})=>e?`timed out after ${t} milliseconds`:i?"was canceled":r!==void 0?`failed with ${r}`:n!==void 0?`was killed with ${n} (${o})`:s!==void 0?`failed with exit code ${s}`:"failed",yr=({stdout:e,stderr:t,all:r,error:n,signal:o,exitCode:s,command:i,escapedCommand:c,timedOut:u,isCanceled:d,killed:f,parsed:{options:{timeout:h}}})=>{s=s===null?void 0:s,o=o===null?void 0:o;let m=o===void 0?void 0:hr[o].description,g=n&&n.code,S=`Command ${gr({timedOut:u,timeout:h,errorCode:g,signal:o,signalDescription:m,exitCode:s,isCanceled:d})}: ${i}`,I=Object.prototype.toString.call(n)==="[object Error]",L=I?`${S}
${n.message}`:S,B=[L,t,e].filter(Boolean).join(`
`);return I?(n.originalMessage=n.message,n.message=B):n=new Error(B),n.shortMessage=L,n.command=i,n.escapedCommand=c,n.exitCode=s,n.signal=o,n.signalDescription=m,n.stdout=e,n.stderr=t,r!==void 0&&(n.all=r),"bufferedData"in n&&delete n.bufferedData,n.failed=!0,n.timedOut=!!u,n.isCanceled=d,n.killed=f&&!u,n};Ct.exports=yr});var Rt=a((Ko,le)=>{"use strict";var X=["stdin","stdout","stderr"],Sr=e=>X.some(t=>e[t]!==void 0),Gt=e=>{if(!e)return;let{stdio:t}=e;if(t===void 0)return X.map(n=>e[n]);if(Sr(e))throw new Error(`It's not possible to provide \`stdio\` in combination with one of ${X.map(n=>`\`${n}\``).join(", ")}`);if(typeof t=="string")return t;if(!Array.isArray(t))throw new TypeError(`Expected \`stdio\` to be of type \`string\` or \`Array\`, got \`${typeof t}\``);let r=Math.max(t.length,X.length);return Array.from({length:r},(n,o)=>t[o])};le.exports=Gt;le.exports.node=e=>{let t=Gt(e);return t==="ipc"?"ipc":t===void 0||typeof t=="string"?[t,t,t,"ipc"]:t.includes("ipc")?t:[...t,"ipc"]}});var Ot=a((Wo,K)=>{K.exports=["SIGABRT","SIGALRM","SIGHUP","SIGINT","SIGTERM"];process.platform!=="win32"&&K.exports.push("SIGVTALRM","SIGXCPU","SIGXFSZ","SIGUSR2","SIGTRAP","SIGSYS","SIGQUIT","SIGIOT");process.platform==="linux"&&K.exports.push("SIGIO","SIGPOLL","SIGPWR","SIGSTKFLT","SIGUNUSED")});var kt=a((zo,R)=>{var l=global.process,w=function(e){return e&&typeof e=="object"&&typeof e.removeListener=="function"&&typeof e.emit=="function"&&typeof e.reallyExit=="function"&&typeof e.listeners=="function"&&typeof e.kill=="function"&&typeof e.pid=="number"&&typeof e.on=="function"};w(l)?(qt=require("assert"),A=Ot(),Nt=/^win/i.test(l.platform),_=require("events"),typeof _!="function"&&(_=_.EventEmitter),l.__signal_exit_emitter__?p=l.__signal_exit_emitter__:(p=l.__signal_exit_emitter__=new _,p.count=0,p.emitted={}),p.infinite||(p.setMaxListeners(1/0),p.infinite=!0),R.exports=function(e,t){if(!w(global.process))return function(){};qt.equal(typeof e,"function","a callback must be provided for exit handler"),G===!1&&fe();var r="exit";t&&t.alwaysLast&&(r="afterexit");var n=function(){p.removeListener(r,e),p.listeners("exit").length===0&&p.listeners("afterexit").length===0&&W()};return p.on(r,e),n},W=function(){!G||!w(global.process)||(G=!1,A.forEach(function(t){try{l.removeListener(t,z[t])}catch{}}),l.emit=V,l.reallyExit=pe,p.count-=1)},R.exports.unload=W,b=function(t,r,n){p.emitted[t]||(p.emitted[t]=!0,p.emit(t,r,n))},z={},A.forEach(function(e){z[e]=function(){if(w(global.process)){var r=l.listeners(e);r.length===p.count&&(W(),b("exit",null,e),b("afterexit",null,e),Nt&&e==="SIGHUP"&&(e="SIGINT"),l.kill(l.pid,e))}}}),R.exports.signals=function(){return A},G=!1,fe=function(){G||!w(global.process)||(G=!0,p.count+=1,A=A.filter(function(t){try{return l.on(t,z[t]),!0}catch{return!1}}),l.emit=$t,l.reallyExit=_t)},R.exports.load=fe,pe=l.reallyExit,_t=function(t){w(global.process)&&(l.exitCode=t||0,b("exit",l.exitCode,null),b("afterexit",l.exitCode,null),pe.call(l,l.exitCode))},V=l.emit,$t=function(t,r){if(t==="exit"&&w(global.process)){r!==void 0&&(l.exitCode=r);var n=V.apply(this,arguments);return b("exit",l.exitCode,null),b("afterexit",l.exitCode,null),n}else return V.apply(this,arguments)}):R.exports=function(){return function(){}};var qt,A,Nt,_,p,W,b,z,G,fe,pe,_t,V,$t});var Bt=a((Vo,Lt)=>{"use strict";var xr=require("os"),wr=kt(),br=1e3*5,vr=(e,t="SIGTERM",r={})=>{let n=e(t);return Ir(e,t,r,n),n},Ir=(e,t,r,n)=>{if(!Er(t,r,n))return;let o=Tr(r),s=setTimeout(()=>{e("SIGKILL")},o);s.unref&&s.unref()},Er=(e,{forceKillAfterTimeout:t},r)=>Pr(e)&&t!==!1&&r,Pr=e=>e===xr.constants.signals.SIGTERM||typeof e=="string"&&e.toUpperCase()==="SIGTERM",Tr=({forceKillAfterTimeout:e=!0})=>{if(e===!0)return br;if(!Number.isFinite(e)||e<0)throw new TypeError(`Expected the \`forceKillAfterTimeout\` option to be a non-negative integer, got \`${e}\` (${typeof e})`);return e},Cr=(e,t)=>{e.kill()&&(t.isCanceled=!0)},Ar=(e,t,r)=>{e.kill(t),r(Object.assign(new Error("Timed out"),{timedOut:!0,signal:t}))},Gr=(e,{timeout:t,killSignal:r="SIGTERM"},n)=>{if(t===0||t===void 0)return n;let o,s=new Promise((c,u)=>{o=setTimeout(()=>{Ar(e,r,u)},t)}),i=n.finally(()=>{clearTimeout(o)});return Promise.race([s,i])},Rr=({timeout:e})=>{if(e!==void 0&&(!Number.isFinite(e)||e<0))throw new TypeError(`Expected the \`timeout\` option to be a non-negative integer, got \`${e}\` (${typeof e})`)},Or=async(e,{cleanup:t,detached:r},n)=>{if(!t||r)return n;let o=wr(()=>{e.kill()});return n.finally(()=>{o()})};Lt.exports={spawnedKill:vr,spawnedCancel:Cr,setupTimeout:Gr,validateTimeout:Rr,setExitHandler:Or}});var Mt=a((Yo,jt)=>{"use strict";var x=e=>e!==null&&typeof e=="object"&&typeof e.pipe=="function";x.writable=e=>x(e)&&e.writable!==!1&&typeof e._write=="function"&&typeof e._writableState=="object";x.readable=e=>x(e)&&e.readable!==!1&&typeof e._read=="function"&&typeof e._readableState=="object";x.duplex=e=>x.writable(e)&&x.readable(e);x.transform=e=>x.duplex(e)&&typeof e._transform=="function";jt.exports=x});var Ft=a((Qo,Ut)=>{"use strict";var{PassThrough:qr}=require("stream");Ut.exports=e=>{e={...e};let{array:t}=e,{encoding:r}=e,n=r==="buffer",o=!1;t?o=!(r||n):r=r||"utf8",n&&(r=null);let s=new qr({objectMode:o});r&&s.setEncoding(r);let i=0,c=[];return s.on("data",u=>{c.push(u),o?i=c.length:i+=u.length}),s.getBufferedValue=()=>t?c:n?Buffer.concat(c,i):c.join(""),s.getBufferedLength=()=>i,s}});var Dt=a((Zo,$)=>{"use strict";var{constants:Nr}=require("buffer"),_r=require("stream"),{promisify:$r}=require("util"),kr=Ft(),Lr=$r(_r.pipeline),Y=class extends Error{constructor(){super("maxBuffer exceeded"),this.name="MaxBufferError"}};async function me(e,t){if(!e)throw new Error("Expected a stream");t={maxBuffer:1/0,...t};let{maxBuffer:r}=t,n=kr(t);return await new Promise((o,s)=>{let i=c=>{c&&n.getBufferedLength()<=Nr.MAX_LENGTH&&(c.bufferedData=n.getBufferedValue()),s(c)};(async()=>{try{await Lr(e,n),o()}catch(c){i(c)}})(),n.on("data",()=>{n.getBufferedLength()>r&&i(new Y)})}),n.getBufferedValue()}$.exports=me;$.exports.buffer=(e,t)=>me(e,{...t,encoding:"buffer"});$.exports.array=(e,t)=>me(e,{...t,array:!0});$.exports.MaxBufferError=Y});var Xt=a((Jo,Ht)=>{"use strict";var{PassThrough:Br}=require("stream");Ht.exports=function(){var e=[],t=new Br({objectMode:!0});return t.setMaxListeners(0),t.add=r,t.isEmpty=n,t.on("unpipe",o),Array.prototype.slice.call(arguments).forEach(r),t;function r(s){return Array.isArray(s)?(s.forEach(r),this):(e.push(s),s.once("end",o.bind(null,s)),s.once("error",t.emit.bind(t,"error")),s.pipe(t,{end:!1}),this)}function n(){return e.length==0}function o(s){e=e.filter(function(i){return i!==s}),!e.length&&t.readable&&t.end()}}});var Vt=a((es,zt)=>{"use strict";var Wt=Mt(),Kt=Dt(),jr=Xt(),Mr=(e,t)=>{t===void 0||e.stdin===void 0||(Wt(t)?t.pipe(e.stdin):e.stdin.end(t))},Ur=(e,{all:t})=>{if(!t||!e.stdout&&!e.stderr)return;let r=jr();return e.stdout&&r.add(e.stdout),e.stderr&&r.add(e.stderr),r},he=async(e,t)=>{if(e){e.destroy();try{return await t}catch(r){return r.bufferedData}}},ge=(e,{encoding:t,buffer:r,maxBuffer:n})=>{if(!(!e||!r))return t?Kt(e,{encoding:t,maxBuffer:n}):Kt.buffer(e,{maxBuffer:n})},Fr=async({stdout:e,stderr:t,all:r},{encoding:n,buffer:o,maxBuffer:s},i)=>{let c=ge(e,{encoding:n,buffer:o,maxBuffer:s}),u=ge(t,{encoding:n,buffer:o,maxBuffer:s}),d=ge(r,{encoding:n,buffer:o,maxBuffer:s*2});try{return await Promise.all([i,c,u,d])}catch(f){return Promise.all([{error:f,signal:f.signal,timedOut:f.timedOut},he(e,c),he(t,u),he(r,d)])}},Dr=({input:e})=>{if(Wt(e))throw new TypeError("The `input` option cannot be a stream in sync mode")};zt.exports={handleInput:Mr,makeAllStream:Ur,getSpawnedResult:Fr,validateInputSync:Dr}});var Qt=a((ts,Yt)=>{"use strict";var Hr=(async()=>{})().constructor.prototype,Xr=["then","catch","finally"].map(e=>[e,Reflect.getOwnPropertyDescriptor(Hr,e)]),Kr=(e,t)=>{for(let[r,n]of Xr){let o=typeof t=="function"?(...s)=>Reflect.apply(n.value,t(),s):n.value.bind(t);Reflect.defineProperty(e,r,{...n,value:o})}return e},Wr=e=>new Promise((t,r)=>{e.on("exit",(n,o)=>{t({exitCode:n,signal:o})}),e.on("error",n=>{r(n)}),e.stdin&&e.stdin.on("error",n=>{r(n)})});Yt.exports={mergePromise:Kr,getSpawnedPromise:Wr}});var en=a((ns,Jt)=>{"use strict";var Zt=(e,t=[])=>Array.isArray(t)?[e,...t]:[e],zr=/^[\w.-]+$/,Vr=/"/g,Yr=e=>typeof e!="string"||zr.test(e)?e:`"${e.replace(Vr,'\\"')}"`,Qr=(e,t)=>Zt(e,t).join(" "),Zr=(e,t)=>Zt(e,t).map(r=>Yr(r)).join(" "),Jr=/ +/g,eo=e=>{let t=[];for(let r of e.trim().split(Jr)){let n=t[t.length-1];n&&n.endsWith("\\")?t[t.length-1]=`${n.slice(0,-1)} ${r}`:t.push(r)}return t};Jt.exports={joinCommand:Qr,getEscapedCommand:Zr,parseCommand:eo}});var an=a((rs,O)=>{"use strict";var to=require("path"),ye=require("child_process"),no=lt(),ro=pt(),oo=gt(),so=wt(),Q=At(),nn=Rt(),{spawnedKill:io,spawnedCancel:co,setupTimeout:ao,validateTimeout:uo,setExitHandler:lo}=Bt(),{handleInput:fo,getSpawnedResult:po,makeAllStream:mo,validateInputSync:ho}=Vt(),{mergePromise:tn,getSpawnedPromise:go}=Qt(),{joinCommand:rn,parseCommand:on,getEscapedCommand:sn}=en(),yo=1e3*1e3*100,So=({env:e,extendEnv:t,preferLocal:r,localDir:n,execPath:o})=>{let s=t?{...process.env,...e}:e;return r?oo.env({env:s,cwd:n,execPath:o}):s},cn=(e,t,r={})=>{let n=no._parse(e,t,r);return e=n.command,t=n.args,r=n.options,r={maxBuffer:yo,buffer:!0,stripFinalNewline:!0,extendEnv:!0,preferLocal:!1,localDir:r.cwd||process.cwd(),execPath:process.execPath,encoding:"utf8",reject:!0,cleanup:!0,all:!1,windowsHide:!0,...r},r.env=So(r),r.stdio=nn(r),process.platform==="win32"&&to.basename(e,".exe")==="cmd"&&t.unshift("/q"),{file:e,args:t,options:r,parsed:n}},k=(e,t,r)=>typeof t!="string"&&!Buffer.isBuffer(t)?r===void 0?void 0:"":e.stripFinalNewline?ro(t):t,Z=(e,t,r)=>{let n=cn(e,t,r),o=rn(e,t),s=sn(e,t);uo(n.options);let i;try{i=ye.spawn(n.file,n.args,n.options)}catch(g){let y=new ye.ChildProcess,S=Promise.reject(Q({error:g,stdout:"",stderr:"",all:"",command:o,escapedCommand:s,parsed:n,timedOut:!1,isCanceled:!1,killed:!1}));return tn(y,S)}let c=go(i),u=ao(i,n.options,c),d=lo(i,n.options,u),f={isCanceled:!1};i.kill=io.bind(null,i.kill.bind(i)),i.cancel=co.bind(null,i,f);let m=so(async()=>{let[{error:g,exitCode:y,signal:S,timedOut:I},L,B,yn]=await po(i,n.options,d),xe=k(n.options,L),we=k(n.options,B),be=k(n.options,yn);if(g||y!==0||S!==null){let ve=Q({error:g,exitCode:y,signal:S,stdout:xe,stderr:we,all:be,command:o,escapedCommand:s,parsed:n,timedOut:I,isCanceled:f.isCanceled,killed:i.killed});if(!n.options.reject)return ve;throw ve}return{command:o,escapedCommand:s,exitCode:0,stdout:xe,stderr:we,all:be,failed:!1,timedOut:!1,isCanceled:!1,killed:!1}});return fo(i,n.options.input),i.all=mo(i,n.options),tn(i,m)};O.exports=Z;O.exports.sync=(e,t,r)=>{let n=cn(e,t,r),o=rn(e,t),s=sn(e,t);ho(n.options);let i;try{i=ye.spawnSync(n.file,n.args,n.options)}catch(d){throw Q({error:d,stdout:"",stderr:"",all:"",command:o,escapedCommand:s,parsed:n,timedOut:!1,isCanceled:!1,killed:!1})}let c=k(n.options,i.stdout,i.error),u=k(n.options,i.stderr,i.error);if(i.error||i.status!==0||i.signal!==null){let d=Q({stdout:c,stderr:u,error:i.error,signal:i.signal,exitCode:i.status,command:o,escapedCommand:s,parsed:n,timedOut:i.error&&i.error.code==="ETIMEDOUT",isCanceled:!1,killed:i.signal!==null});if(!n.options.reject)return d;throw d}return{command:o,escapedCommand:s,exitCode:0,stdout:c,stderr:u,failed:!1,timedOut:!1,isCanceled:!1,killed:!1}};O.exports.command=(e,t)=>{let[r,...n]=on(e);return Z(r,n,t)};O.exports.commandSync=(e,t)=>{let[r,...n]=on(e);return Z.sync(r,n,t)};O.exports.node=(e,t,r={})=>{t&&!Array.isArray(t)&&typeof t=="object"&&(r=t,t=[]);let n=nn.node(r),o=process.execArgv.filter(c=>!c.startsWith("--inspect")),{nodePath:s=process.execPath,nodeOptions:i=o}=r;return Z(s,[...i,e,...Array.isArray(t)?t:[]],{...r,stdin:void 0,stdout:void 0,stderr:void 0,stdio:n,shell:!1})}});var bo={};In(bo,{default:()=>wo});module.exports=En(bo);var v=require("@raycast/api"),mn=require("child_process");var un=Ee(require("node:process"),1),dn=Ee(an(),1);async function ln(e,{humanReadableOutput:t=!0}={}){if(un.default.platform!=="darwin")throw new Error("macOS only");let r=t?[]:["-ss"],{stdout:n}=await(0,dn.default)("osascript",["-e",e,r]);return n}var Se="/usr/local/bin/piactl",fn=` tell application "Private Internet Access"
      if not application "Private Internet Access" is running then
        activate

        set _maxOpenWaitTimeInSeconds to 5
        set _openCounter to 1
        repeat until application "Private Internet Access" is running
          delay 1
          set _openCounter to _openCounter + 1
          if _openCounter > _maxOpenWaitTimeInSeconds then exit repeat
        end repeat
      end if
    end tell`;async function pn(e){if(!(await(0,v.getApplications)()).find(n=>n.name==="Private Internet Access")){await(0,v.showHUD)("Private Internet Access app not found");return}await(0,v.closeMainWindow)(),await ln(fn),await gn(`${Se} ${e}`)}async function xo(){try{let{stdout:e}=await gn(`${Se} get connectionstate`),t=e.trim();return t==="Connected"||t==="Connecting"||t==="DisconnectingToReconnect"}catch(e){return console.error("Error checking PIA connection:",e),!1}}async function hn(e){e&&await pn(`set region ${e}`),await pn("connect"),await xo()&&await(0,v.showHUD)(`Private Internet Access connected (${e})`)}function gn(e){return new Promise((t,r)=>{(0,mn.exec)(e,(n,o,s)=>{n?r(n):t({stdout:o,stderr:s})})})}var wo=async()=>{await hn()};