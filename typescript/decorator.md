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
// 引数としてコンストラクタ関数を受け取らなければならないのでLogger(constructor: Function)と定義しているが、引数で受け取ったものを使わない場合、Logger(_: Function)とアンダースコアで書くことにより、TypeScriptに引数は受け取るが、使わないということを伝えることができる。

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

デコレータでDOM操作の例
```
function WithTemplate(template: string, hookId: string) {
  return function (constructor: any) {
    const hookEl = document.getElementById(hookId);
    const p = new constructor();
    if (hookEl) {
      hookEl.innerHTML = template;
      hookEl.querySelector("h1")!.textContent = p.name;
    }
  };
}

@WithTemplate("<h1>Personオブジェクト</h1>", "app")
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}

const pers = new Person();
// 画面にはh1タグで囲まれたMaxが表示される
```


# 複数のデコレータの追加
クラスには複数のデコレータを追加できる。
デコレータ関数の作成については上から順に実行される。しかし、デコレータ関数はしたから上に実行される。
```
function Logger(logString: string) {
  console.log("LOGGER ファクトリ");
  return function (constructor: Function) {
    console.log(logString);
    console.log(constructor);
  };
}

function WithTemplate(template: string, hookId: string) {
  console.log("TEMPLATE ファクトリ");
  return function (constructor: any) {
    console.log("テンプレートを表示");
    const hookEl = document.getElementById(hookId);
    const p = new constructor();
    if (hookEl) {
      hookEl.innerHTML = template;
      hookEl.querySelector("h1")!.textContent = p.name;
    }
  };
}

@Logger("ログ出力中")
@WithTemplate("<h1>Personオブジェクト</h1>", "app")
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}

const pers = new Person();
```
この場合コンソールには

LOGGER ファクトリ
TEMPLATE ファクトリ
テンプレートを表示
Personオブジェクトを作成中
ログ出力中
class Person {
    constructor() {
        this.name = "Max";
        console.log("Personオブジェクトを作成中");
    }
}
Personオブジェクトを作成中

の順で表示される。



# デコレータを追加できる場所
## プロパティ
デコレータはプロパティにも追加できる。プロパティのデコレータ関数は引数を２種類受け取る。1つ目の引数には、インスタンスのプロパティにデコレータを設定した場合、クラスのプロトタイプが渡される。インスタンスプロパティではなく、スタティックプロパティに設定した場合は、コンストラクタ関数が渡される。2つ目はプロパティの名前。
```
function Log(target: any, propertyName: string | symbol) {
  console.log("Property デコレータ");
  console.log(target, propertyName);
}

// 外から読み書きしてほしくないプロパティをアンダーバーで開始するのはただの慣習であるため、構文としての意味はない。(下の_price)
class Product {
  @Log
  title: string;
  private _price: number;

  set price(val: number) {
    if (val > 0) {
      this._price = val;
    } else {
      throw new Error("不正な価格です。 - 0以下は設定できません");
    }
  }

  constructor(t: string, p: number) {
    this.title = t;
    this._price = p;
  }

  getPriceWithTax(tax: number) {
    return this._price * (1 + tax);
  }
}
```
