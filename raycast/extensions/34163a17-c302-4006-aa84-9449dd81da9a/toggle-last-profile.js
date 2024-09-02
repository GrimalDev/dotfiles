"use strict";var g=Object.create;var a=Object.defineProperty;var P=Object.getOwnPropertyDescriptor;var S=Object.getOwnPropertyNames;var x=Object.getPrototypeOf,A=Object.prototype.hasOwnProperty;var V=(e,t)=>{for(var n in t)a(e,n,{get:t[n],enumerable:!0})},f=(e,t,n,o)=>{if(t&&typeof t=="object"||typeof t=="function")for(let s of S(t))!A.call(e,s)&&s!==n&&a(e,s,{get:()=>t[s],enumerable:!(o=P(t,s))||o.enumerable});return e};var b=(e,t,n)=>(n=e!=null?g(x(e)):{},f(t||!e||!e.__esModule?a(n,"default",{value:e,enumerable:!0}):n,e)),h=e=>f(a({},"__esModule",{value:!0}),e);var R={};V(R,{default:()=>O});module.exports=h(R);var r=require("@raycast/api");var c=require("child_process");var d=b(require("node:process"),1),y=require("node:util"),u=require("node:child_process"),E=(0,y.promisify)(u.execFile);async function i(e,{humanReadableOutput:t=!0}={}){if(d.default.platform!=="darwin")throw new Error("macOS only");let n=t?[]:["-ss"],{stdout:o}=await E("osascript",["-e",e,n]);return o.trim()}var N=require("util"),I=(0,N.promisify)(c.exec),p=async()=>{try{return await i(`
      try
        tell application "System Events"
          tell process "OpenVPN Connect"
            -- Check if the menu bar item 1 of menu bar 2 exists
            if exists menu bar item 1 of menu bar 2 then
              return true
            else
              return false
            end if
          end tell
        end tell
      on error
        return false
      end try
    `)==="true"}catch{return!1}},l=async()=>{try{(0,c.execSync)('"/Applications/OpenVPN Connect/OpenVPN Connect.app/contents/MacOS/OpenVPN Connect"'),(0,c.execSync)('"/Applications/OpenVPN Connect/OpenVPN Connect.app/contents/MacOS/OpenVPN Connect" --minimize')}catch(e){console.error(e)}};var m=async()=>{let t=(await i(`
    tell application "System Events" to tell process "OpenVPN Connect"
      set menuBarItems to name of every menu item of menu 1 of menu bar item 1 of menu bar 2
      return menuBarItems
    end tell
`)).split(", "),n=t.includes("Disconnect"),o=t.indexOf(n?"Disconnect":"Connect")-1,s=t[o];return{isConnected:n,selectedProfileName:s}},w=async()=>await p()?await i(`
    try
      tell application "System Events" to tell process "OpenVPN Connect"
        click menu item "Disconnect" of menu 1 of menu bar item 1 of menu bar 2
        return ""
      end tell
    on error
		  return "Already disconnected"
	  end try
  `):void 0,C=async e=>{await p()||l();let n=await m();return await i(`
    try
      tell application "System Events" to tell process "OpenVPN Connect"
        click menu item "${e}" of menu "${n.selectedProfileName}" of menu item "${n.selectedProfileName}" of menu 1 of menu bar item 1 of menu bar 2
        return ""
      end tell
    on error
		  return "Failed to connect"
	  end try
  `)};async function O(){await(0,r.closeMainWindow)(),await p()||l();let t=await m(),n;if(t.isConnected?n=await w():n=await C(t.selectedProfileName),n){await(0,r.showToast)({style:r.Toast.Style.Failure,title:n});return}await(0,r.showToast)({style:t.isConnected?r.Toast.Style.Failure:r.Toast.Style.Success,title:`${t.selectedProfileName} ${t.isConnected?"DISCONNECTED":"CONNECTED"}`})}
