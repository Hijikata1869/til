# クラス
class Department {
  name: string;

  constructor(n: string) {
    this.name = n;
  }

  // describeメソッドを定義
  // この引数thisに, Departmentという型定義が意味することは、describe()が実行されたとき、thisは常にDepartmentクラスをベースにしたインスタンスを参照する必要があるということ。Departmentクラスベースのインスタンスでない場合は、同じ構造のオブジェクトを参照する必要がある。この場合、string型のnameプロパティがあり、describeメソッドが実装されているということ。
  describe(this: Department) {
    console.log("Department: " + this.name);
  }
}

// Departmentクラスベースのインスタンスを作成
const accounting = new Department("Accounting");
console.log(accounting.name); // "Accounting"
accounting.describe(); // "Department: Accounting"

// 以下はオブジェクトリテラルに基づいて作成されたオブジェクトであり、クラスに基づいて作成されたオブジェクトではない。
// describeプロパティの値にはdescribeメソッドの実行結果ではなく、describeメソッドそのものを渡している。(実行結果を渡したければdescribe()と()をつける)
// そのため、nameプロパティが抜けているとDepartmentクラスと構造が異なるため、以下で実行しているaccountingCopyのdescribeメソッドはエラーになる
// 逆に言えば構造さえ一緒なら参照先がDepartmentクラスのインスタンスでなくとも良い
const accountingCopy = { name: "DUMMY", describe: accounting.describe };

accountingCopy.describe(); // "Department: Accounting"

# this
クラスの中のthisというキーワードは基本的にその関数を呼び出すための責任があろうオブジェクトを参照する。
上の例で言えば、describeメソッドのthisは.(ドット)の前にあるものを参照することになる。19行目ならDepartmentクラスベースのオブジェクトを、26行目ならオブジェクトリテラルで作られた、Departmentクラスベースでないオブジェクトを参照している。

# private, public修飾子
class Department {
  // アクセス修飾子はpublicとprivateの２つがあり、publicはデフォルトなので基本的に記載する必要はない。publicの場合クラスの外からアクセスすることができる。学習のためわざと書いている。
  public name: string;
  private employees: string[] = [];

  constructor(n: string) {
    this.name = n;
  }

  describe(this: Department) {
    console.log("Department: " + this.name);
  }

  addEmployee(employee: string) {
    this.employees.push(employee);
  }

  printEmployeeInformation() {
    console.log(this.employees.length);
    console.log(this.employees);
  }
}

const accounting = new Department("Accounting");
accounting.name = "NEW DEPARTMENT" // 動作する。nameプロパティが "NEW DEPARTMENT" になる。
accounting.employees[2] = "Anna" // employeesは外部からアクセスできないのでエラーになる。

# プロパティ初期化のショートカット構文
class Department {
  // id: string;
  // name: string;
  private employees: string[] = [];

  // ここではprivateもpublicも省略不可。ここで書いたプロパティ名がそのままプロパティ名として使える
  constructor(private id: string, public name: string) {}

  describe(this: Department) {
    console.log(`Department (${this.id}): ${this.name}`);
  }

  addEmployee(employee: string) {
    this.employees.push(employee);
  }

  printEmployeeInformation() {
    console.log(this.employees.length);
    console.log(this.employees);
  }
}

const accounting = new Department("d1", "NEW NAME");

accounting.describe(); // Department (d1): NEW NAME

# readonly修飾子
class Department {
  // private readonly id: string;
  // name: string;
  private employees: string[] = [];

  // readonly修飾子をつけると、プロパティを変更するコードをエラーにするので、一度初期値が設定された後は変わらないことを確実にすることができる。
  constructor(private readonly id: string, public name: string) {}

  describe(this: Department) {
    console.log(`Department (${this.id}): ${this.name}`);
  }

  addEmployee(employee: string) {
    this.id = "d2" // エラー
    this.employees.push(employee);
  }

  printEmployeeInformation() {
    console.log(this.employees.length);
    console.log(this.employees);
  }
}

# 継承
上記のDepartmentクラスを継承した新しい、例えばIT部門のクラスを作成する場合、

class Department {
  ...
}

class ITDepartment extends Department {
  ...
}

このようにextendsキーワードを使うことでベースクラス(継承元)を参照した新しいクラスを作成することができる。クラスの継承は1つのクラスからしか継承できない。複数のクラスから継承することはできない。
クラスを継承すると、継承先でconstructorを定義していなければ、継承元のconstructorが使われ、自動的に継承元となったクラスのプロパティやメソッドを引き継ぐ。

# super
継承先のクラスのconstructorの中で、super()を使うと、継承元のconstructorを呼び出すことができる。

class Practice {
  constructor(private readonly id: string, public name: string) {}
}

class SecondPractice extends Practice {
  constructor() {
    super("d1", "Second"); // id: "d1", name: "Second"
  }
}

上記のコードではインスタンス化する前にクラスの中でidとnameの値を定義しているが、インスタンス化と同時に定義したい場合はconstructorの引数として渡せば良い。例えば、idはインスタンス化する際に定義、nameはクラス内で定義する場合constructorの引数として受け取る。この場合、idはprivateのreadonlyになっている。以下コード。

class Practice {
  constructor(private readonly id: string, public name: string) {}
}

class SecondPractice extends Practice {
  constructor(id: string) {
    super(id, "Second"); // id: "d1", name: "Second"
  }
}

const secondPractice = new SecondPractice("secondId"); // id: "secondId", name: "Second"

thisというキーワードを使う場合は、superよりも後ろで定義する必要がある。

class SecondPractice extends Practice {
  constructor(id: string, public admins: string[]) {
    super(id, "Second");
    this.admins = admins;
  }
}

# protected修飾子
private修飾子をつけたプロパティはそれを定義したクラス内でのみアクセスでき、継承先のクラス内からはアクセスできない。しかし、このprivateをprotected修飾子に変えることで引き続き外部からはアクセスできないまま、継承先のクラスではアクセスさせることができる。そうすることで、プロパティのオーバーライドができる。
class Practice {
  constructor(
    public id: string,
    public name: string,
    protected members: string[]
  ) {}

  addMember(newMember: string) {
    this.members.push(newMember);
  }

  showMembers() {
    console.log(this.members);
  }
}

class SecondPractice extends Practice {
  constructor(id: string) {
    super(id, "Second", []);
  }

  addMember(newMember: string) {
    if (newMember === "Foo") {
      return;
    }
    this.members.push(newMember);
  }
}

const secondPractice = new SecondPractice("Second");
secondPractice.addMember("Max");
secondPractice.addMember("Foo");

secondPractice.showMembers(); // ["Max"]

# GetterとSetter
privateを設定したプロパティは基本的に外部から値を取り出したり、セットしたりすることはできない。しかし、ゲッターやセッターをクラス内に定義することでそれができるようになる。

class Practice {
  constructor(private members: string[]) {}

  // Getterの定義
  get mostRecentPracticeMember() {
    return this.members[0];
  }

  // Setterの定義
  set mostRecentPracticeMember(newMember: string) {
    this.members.push(newMember);
  }

  addMember(newMember: string) {
    this.members.push(newMember);
  }
}

const practice = new Practice([]);

// セッターを使う
practice.mostRecentPracticeMember = "Max";

// ゲッターを使う
practice.mostRecentPracticeMember;  // "Max"

# staticプロパティ、staticメソッド
クラスの中に記述することで、インスタンス化せずにプロパティ、メソッドを使うことができる。
class Sample {
  static foo = "bar"

  static hoge(name: string) {
    return { huga: name }
  }
}

Sample.foo // "bar"
Sample.hoge("hogehoge") // { name: hogehoge }

# abstract(抽象)
継承されたクラス側で何らかのメソッドを強制的に定義、オーバーライドしてほしいときに使える。abstractをつけたクラスはインスタンス化できないので注意。それを継承したサブクラスは問題なくインスタンス化できる。抽象化(abstructをつけた)したクラスで抽象化したメソッドを定義した場合、継承先のクラスではそのメソッドを定義しないとエラーになる。

// ベースクラス側の定義
abstract class Sample {
  constructor ( ... ) {
    ...
  }

  // こう定義するとサブクラスではここに定義されている通りのメソッドを実装しなければならない。つまりというメソッド名はfoobar、thisのオブジェクトはSampleクラスか、Sampleクラスを継承したサブクラスである必要がある。そして、戻り値はvoid、つまり何も返さない実装にする必要がある。
  abstract foobar(this: Sample): void
}

# シングルトンパターン
シングルトンとは、オブジェクト指向プログラミングにおけるクラスのデザインパターンの一つで、実行時にそのクラスのインスタンスが必ず単一になるよう設計すること。（参考：https://e-words.jp/w/%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%AB%E3%83%88%E3%83%B3.html）

typescriptで実装する場合、constructorにprivateをつける。

class Sample {
  private constructor ( ... ) {
    ...
  }
}