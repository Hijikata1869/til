# ジェネリック型
ジェネリック型とは、他の特定の型と結合された型。「汎用型」とも呼ばれる。

// 配列のジェネリック型
const foobar: Array<string> = []; // foober: string[]と一緒

// Promiseのジェネリック型
// string型のデータを返すことを明示的に示すことができる。
const promise: Promise<string> = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve("終わりました！");
  }, 2000);
});