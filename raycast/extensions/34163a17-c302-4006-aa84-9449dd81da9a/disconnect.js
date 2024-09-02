"use strict";var O=Object.create;var i=Object.defineProperty;var w=Object.getOwnPropertyDescriptor;var P=Object.getOwnPropertyNames;var g=Object.getPrototypeOf,x=Object.prototype.hasOwnProperty;var N=(e,t)=>{for(var n in t)i(e,n,{get:t[n],enumerable:!0})},m=(e,t,n,s)=>{if(t&&typeof t=="object"||typeof t=="function")for(let o of P(t))!x.call(e,o)&&o!==n&&i(e,o,{get:()=>t[o],enumerable:!(s=w(t,o))||s.enumerable});return e};var S=(e,t,n)=>(n=e!=null?O(g(e)):{},m(t||!e||!e.__esModule?i(n,"default",{value:e,enumerable:!0}):n,e)),C=e=>m(i({},"__esModule",{value:!0}),e);var b={};N(b,{default:()=>y});module.exports=C(b);var r=require("@raycast/api");var p=require("child_process");var u=S(require("node:process"),1),l=require("node:util"),c=require("node:child_process"),A=(0,l.promisify)(c.execFile);async function a(e,{humanReadableOutput:t=!0}={}){if(u.default.platform!=="darwin")throw new Error("macOS only");let n=t?[]:["-ss"],{stdout:s}=await A("osascript",["-e",e,n]);return s.trim()}var f=require("util"),F=(0,f.promisify)(p.exec),V=async()=>{try{return await a(`
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
    `)==="true"}catch{return!1}};var d=async()=>await V()?await a(`
    try
      tell application "System Events" to tell process "OpenVPN Connect"
        click menu item "Disconnect" of menu 1 of menu bar item 1 of menu bar 2
        return ""
      end tell
    on error
		  return "Already disconnected"
	  end try
  `):void 0;async function y(){await(0,r.closeMainWindow)();let e=await d();e&&await(0,r.showToast)({style:r.Toast.Style.Failure,title:e})}
