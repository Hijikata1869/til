# ジェネリック型
ジェネリック型とは、他の特定の型と結合された型。「汎用型」とも呼ばれる。「追加の型情報」を切り替えて汎用的に利用できる。
例１）Array<string>(他の型はstring)
例１）Array<number>(他の型はnumber)

// 配列のジェネリック型
const foobar: Array<string> = []; // foobar: string[]と一緒

// Promiseのジェネリック型。この場合、string型のデータを返すことを明示的に示すことができる。
const promise: Promise<string> = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve("終わりました！");
  }, 2000);
});

// 上のPromiseはstring型のデータを返すことをジェネリック型の型定義で示しているため、splitメソッドが使える。これが仮にtoLocaleStringなどのnumber型特有のメソッドを指定した場合、typescriptはエラーを表示する。
promise.then(data => {
  data.split(' ');
})

// 【ジェネリック(汎用)型とは】追加の型情報を提供できる型
// 【ジェネリック型の利用目的】TypeScriptにおける型安全性を高めることができる / 自動補完等の開発サポートを向上することができる