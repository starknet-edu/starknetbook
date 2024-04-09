"use strict";
/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
exports.id = "vendor-chunks/isomorphic-fetch";
exports.ids = ["vendor-chunks/isomorphic-fetch"];
exports.modules = {

/***/ "(ssr)/./node_modules/isomorphic-fetch/fetch-npm-node.js":
/*!*********************************************************!*\
  !*** ./node_modules/isomorphic-fetch/fetch-npm-node.js ***!
  \*********************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

eval("\nvar realFetch = __webpack_require__(/*! node-fetch */ \"(ssr)/./node_modules/node-fetch/lib/index.mjs\");\nmodule.exports = function(url, options) {\n    if (/^\\/\\//.test(url)) {\n        url = \"https:\" + url;\n    }\n    return realFetch.call(this, url, options);\n};\nif (!global.fetch) {\n    global.fetch = module.exports;\n    global.Response = realFetch.Response;\n    global.Headers = realFetch.Headers;\n    global.Request = realFetch.Request;\n}\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKHNzcikvLi9ub2RlX21vZHVsZXMvaXNvbW9ycGhpYy1mZXRjaC9mZXRjaC1ucG0tbm9kZS5qcyIsIm1hcHBpbmdzIjoiQUFBYTtBQUViLElBQUlBLFlBQVlDLG1CQUFPQSxDQUFDO0FBQ3hCQyxPQUFPQyxPQUFPLEdBQUcsU0FBU0MsR0FBRyxFQUFFQyxPQUFPO0lBQ3JDLElBQUksUUFBUUMsSUFBSSxDQUFDRixNQUFNO1FBQ3RCQSxNQUFNLFdBQVdBO0lBQ2xCO0lBQ0EsT0FBT0osVUFBVU8sSUFBSSxDQUFDLElBQUksRUFBRUgsS0FBS0M7QUFDbEM7QUFFQSxJQUFJLENBQUNHLE9BQU9DLEtBQUssRUFBRTtJQUNsQkQsT0FBT0MsS0FBSyxHQUFHUCxPQUFPQyxPQUFPO0lBQzdCSyxPQUFPRSxRQUFRLEdBQUdWLFVBQVVVLFFBQVE7SUFDcENGLE9BQU9HLE9BQU8sR0FBR1gsVUFBVVcsT0FBTztJQUNsQ0gsT0FBT0ksT0FBTyxHQUFHWixVQUFVWSxPQUFPO0FBQ25DIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vZXJjMjBfY2Fpcm9fcmVhY3QvLi9ub2RlX21vZHVsZXMvaXNvbW9ycGhpYy1mZXRjaC9mZXRjaC1ucG0tbm9kZS5qcz80ZWYyIl0sInNvdXJjZXNDb250ZW50IjpbIlwidXNlIHN0cmljdFwiO1xuXG52YXIgcmVhbEZldGNoID0gcmVxdWlyZSgnbm9kZS1mZXRjaCcpO1xubW9kdWxlLmV4cG9ydHMgPSBmdW5jdGlvbih1cmwsIG9wdGlvbnMpIHtcblx0aWYgKC9eXFwvXFwvLy50ZXN0KHVybCkpIHtcblx0XHR1cmwgPSAnaHR0cHM6JyArIHVybDtcblx0fVxuXHRyZXR1cm4gcmVhbEZldGNoLmNhbGwodGhpcywgdXJsLCBvcHRpb25zKTtcbn07XG5cbmlmICghZ2xvYmFsLmZldGNoKSB7XG5cdGdsb2JhbC5mZXRjaCA9IG1vZHVsZS5leHBvcnRzO1xuXHRnbG9iYWwuUmVzcG9uc2UgPSByZWFsRmV0Y2guUmVzcG9uc2U7XG5cdGdsb2JhbC5IZWFkZXJzID0gcmVhbEZldGNoLkhlYWRlcnM7XG5cdGdsb2JhbC5SZXF1ZXN0ID0gcmVhbEZldGNoLlJlcXVlc3Q7XG59XG4iXSwibmFtZXMiOlsicmVhbEZldGNoIiwicmVxdWlyZSIsIm1vZHVsZSIsImV4cG9ydHMiLCJ1cmwiLCJvcHRpb25zIiwidGVzdCIsImNhbGwiLCJnbG9iYWwiLCJmZXRjaCIsIlJlc3BvbnNlIiwiSGVhZGVycyIsIlJlcXVlc3QiXSwic291cmNlUm9vdCI6IiJ9\n//# sourceURL=webpack-internal:///(ssr)/./node_modules/isomorphic-fetch/fetch-npm-node.js\n");

/***/ })

};
;