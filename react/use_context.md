# useContext

URL: https://ja.react.dev/learn/passing-data-deeply-with-context

props をツリー内の深い位置にまで渡す必要がある場合や、多くのコンポーネントが同じ props を必要としている場合、props の受け渡しは冗長で不便なものとなり得る。コンテクストを使うことで、親コンポーネントが配下のツリー全体にデータを提供できる。

## コンテクストの使い方

### ステップ１： コンテクストの作成

まずはコンテクストを作成する必要があります。複数のコンポーネントから使うことができるように、ファイルを作ってコンテクストをエクスポートする必要があります。

```jsx
import { createContext } from "react";

export const LevelContext = createContext(1);
```

createContext の唯一の引数はデフォルト値です。ここでは、1 という値は最大の見出しに対応するレベルを示していますが、任意の型の値（オブジェクトでも）を渡すことができます。デフォルト値の意味は次のステップで分かります。

### ステップ２：　コンテクストを使用する

React の useContext フックと、作ったコンテクストをインポートします。

```jsx
import { useContext } from "react";
import { LevelContext } from "./LevelContext.js";
```

現在、Heading コンポーネントは level を props から読み取っています。

```jsx
export default function Heading({ level, children }) {
  // ...
}
```

代わりに、props から level を削除し、さきほどインポートした LevelContext から値を読み取るようにします。

```jsx
export default function Heading({ children }) {
  const level = useContext(LevelContext);
  // ...
}
```

useContext はフックです。useState や useReducer も同じですが、フックは React コンポーネント内のトップレベルでのみ呼び出すことができます（ループや条件分岐の中では呼び出せません）。useContext は、Heading コンポーネントが LevelContext を読み取りたいのだということを React に伝えています。

### ステップ３：　コンテクストを提供する

コンテクストを提供するコンポーネントを、コンテクストプロバイダでラップする

```jsx
import { LevelContext } from "./LevelContext.js";

export default function Section({ level, children }) {
  return (
    <section className="section">
      <LevelContext.Provider value={level}>{children}</LevelContext.Provider>
    </section>
  );
}

// これにより、「この <Section> の下にあるコンポーネントが LevelContext の値を要求した場合、この level を渡せ」と React に伝えていることになります。コンポーネントは、UI ツリー内の上側で、最も近い <LevelContext.Provider> の値を使用します。
```

1, <Section> に props として level を渡す。
2, Section は子要素を <LevelContext.Provider value={level}> でラップする。
3, Heading は useContext(LevelContext) とすることで、上にある最も近い LevelContext の値を要求する。
