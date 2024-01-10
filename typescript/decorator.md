# クラスのデコレータ
デコレータは最終的にはただの関数。慣習的に大文字スタートで定義することが多い。デコレータを使用する時には、@をつける。
クラスに対するデコレータは引数を１つ受け取る。デコレータの対象となるものを受け取る。下の場合、受け取るものはコンストラクタ関数。
デコレータはクラスが作成されたときに実行される。インスタンス化のタイミングではない。デコレータはjavascriptはクラスの定義を見つけたとに実行される。クラスのオブジェクトを作成したときではない。
```
// Loggerデコレータ
function Logger(constructor: Function) {
  console.log("ログ出力中");
  console.log(constructor);  // class Person {
                                  constructor() {
                                    this.name = "Max";
                                    console.log("Personオブジェクトを作成中");
                                  }
                                }
                                // クラスは結局のところコンストラクタ関数のシンタックスシュガーであることがわかる。
  
}

@Logger // デコレータを使いたいクラスの前で、@をつけて呼び出す
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}

const pers = new Person();
```


# デコレータファクトリ
デコレータファクトリは、デコレータを何かに割り当てるときにデコレータをカスタマイズできるようにするもの。
デコレータファクトリを使うと、任意の引数を必要な数だけ指定することができるようになる。つまり、デコレータ関数の中で使う値をカスタマイズできるようになる。
```
function Logger(logString: string) {
  return function (constructor: Function) {
    console.log(logString);
    console.log(constructor);
  };
}

@Logger("ログ出力中 - Person")
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}
```