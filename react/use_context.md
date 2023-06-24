# useContext
URL: https://react.dev/learn/passing-data-deeply-with-context

通常、親コンポーネントから子コンポーネントへは、propsを介して情報を渡します。しかし、propsの受け渡しは、途中で多くのコンポーネントを経由したり、アプリ内の多くのコンポーネントが同じ情報を必要としたりすると、冗長になり、不便になることがあります。Contextは、親コンポーネントが、その下にあるツリーのどのコンポーネントに対しても、情報を利用できるようにします。

## propsを渡すことの問題点
propsを渡すことは、UIツリーを通してそれを使用するコンポーネントに明示的にデータをパイプする素晴らしい方法です。
しかし、ツリーを通して深くpropを渡す必要がある場合、あるいは多くのコンポーネントが同じpropを必要とする場合、propsを渡すことは冗長になり、不便になります。最も近い共通の祖先は、データを必要とするコンポーネントから遠く離れている可能性があり、そこまで状態を持ち上げることは「プロップドリリング」と呼ばれる状況につながる可能性があります。

プロップを渡すことなく、ツリー内の必要なコンポーネントにデータを "テレポート "する方法があれば素晴らしいと思いませんか？Reactのコンテキスト機能を使えば、それが可能です。

## コンテキスト：propsを渡す代わりに
コンテキストは、親コンポーネントがその下のツリー全体にデータを提供することを可能にします。コンテキストの使い道はたくさんあります。その一例を示します。この Heading コンポーネントを考えてみましょう：
``` 
// App.js
import Heading from './Heading.js';
import Section from './Section.js';

export default function Page() {
  return (
    <Section>
      <Heading level={1}>Title</Heading>
      <Heading level={2}>Heading</Heading>
      <Heading level={3}>Sub-heading</Heading>
      <Heading level={4}>Sub-sub-heading</Heading>
      <Heading level={5}>Sub-sub-sub-heading</Heading>
      <Heading level={6}>Sub-sub-sub-sub-heading</Heading>
    </Section>
  );
}
```
```
// Section.js
export default function Section({ children }) {
  return (
    <section className="section">
      {children}
    </section>
  );
}
```
```
// Heading.js
export default function Heading({ level, children }) {
  switch (level) {
    case 1:
      return <h1>{children}</h1>;
    case 2:
      return <h2>{children}</h2>;
    case 3:
      return <h3>{children}</h3>;
    case 4:
      return <h4>{children}</h4>;
    case 5:
      return <h5>{children}</h5>;
    case 6:
      return <h6>{children}</h6>;
    default:
      throw Error('Unknown level: ' + level);
  }
}
```

同じセクション内の複数の見出しを常に同じサイズにしたいとします：
```
// App.js
import Heading from './Heading.js';
import Section from './Section.js';

export default function Page() {
  return (
    <Section>
      <Heading level={1}>Title</Heading>
      <Section>
        <Heading level={2}>Heading</Heading>
        <Heading level={2}>Heading</Heading>
        <Heading level={2}>Heading</Heading>
        <Section>
          <Heading level={3}>Sub-heading</Heading>
          <Heading level={3}>Sub-heading</Heading>
          <Heading level={3}>Sub-heading</Heading>
          <Section>
            <Heading level={4}>Sub-sub-heading</Heading>
            <Heading level={4}>Sub-sub-heading</Heading>
            <Heading level={4}>Sub-sub-heading</Heading>
          </Section>
        </Section>
      </Section>
    </Section>
  );
}
```
```
// Section.js
export default function Section({ children }) {
  return (
    <section className="section">
      {children}
    </section>
  );
}
```
```
// Heading.js
export default function Heading({ level, children }) {
  switch (level) {
    case 1:
      return <h1>{children}</h1>;
    case 2:
      return <h2>{children}</h2>;
    case 3:
      return <h3>{children}</h3>;
    case 4:
      return <h4>{children}</h4>;
    case 5:
      return <h5>{children}</h5>;
    case 6:
      return <h6>{children}</h6>;
    default:
      throw Error('Unknown level: ' + level);
  }
}
```
現在、各`<Section>`に個別にlevelプロパティを渡しています：
```
<Section>
  <Heading level={3}>About</Heading>
  <Heading level={3}>Photos</Heading>
  <Heading level={3}>Videos</Heading>
</Section>
```
代わりに、`<Section>`コンポーネントにlevel・プロパティを渡して、`<Heading>`からそれを削除できると良いでしょう。そうすれば、同じセクション内のすべての見出しが同じサイズであることを強制できます：
```
<Section level={3}>
  <Heading>About</Heading>
  <Heading>Photos</Heading>
  <Heading>Videos</Heading>
</Section>
```
しかし、`<Heading>`コンポーネントはどうやって一番近い`<Section>`のレベルを知ることができるのだろうか？それには、子コンポーネントがツリーの上のどこかからデータを "要求 "する方法が必要だ。

小道具だけではそれはできない。そこで、コンテキストの出番となる。これを3つのステップで行います：

・コンテキストを作成します。コンテキストを作成します (見出しレベル用なので、LevelContext と呼ぶことができます)。

・データを必要とするコンポーネントからそのコンテキストを使用します。(Headingは LevelContext を使用します。)

・データを指定するコンポーネントからそのコンテキストを提供します。(Sectionは LevelContext を提供します)。

コンテキストは、親（たとえ遠い親であっても）に対して、その親に含まれるツリー全体にデータを提供します。

## ステップ1：コンテキストの作成
まず、コンテキストを作成する必要があります。それをコンポーネントが使えるように、ファイルからエクスポートする必要があります：
```
// LevelContext.js
import { createContext } from 'react';

export const LevelContext = createContext(1);
```
createContextの引数はデフォルト値だけです。ここでは、1は最大の見出しレベルを指しますが、どんな値でも（オブジェクトでも）渡すことができます。デフォルト値の意味は次のステップで説明します。

## ステップ2：コンテキストを使う
useContextフックをReactとコンテキストからインポートします：
```
import { useContext } from 'react';
import { LevelContext } from './LevelContext.js';
```
現在、Headingコンポーネントはpropsからlevelを読み取ります：
```
export default function Heading({ level, children }) {
  // ...
}
```
代わりに、level propを削除し、先ほどインポートしたコンテキストである LevelContext から値を読み取ります：
```
export default function Heading({ children }) {
  const level = useContext(LevelContext);
  // ...
}
```
useContextはフックです。useStateやuseReducerと同じように、Reactコンポーネントの内部ですぐにHookを呼び出すことしかできません（ループや条件の内部では呼び出せません）。useContextはReactに、HeadingコンポーネントがLevelContextを読みたがっていることを伝えます。

Heading コンポーネントは Level Prop を持たないので、このように JSX で Level Prop を Heading に渡す必要はありません：
```
<Section>
  <Heading level={4}>Sub-sub-heading</Heading>
  <Heading level={4}>Sub-sub-heading</Heading>
  <Heading level={4}>Sub-sub-heading</Heading>
</Section>
```

JSXを更新して、代わりに`<Section>`が受け取るようにする：
```
<Section level={4}>
  <Heading>Sub-sub-heading</Heading>
  <Heading>Sub-sub-heading</Heading>
  <Heading>Sub-sub-heading</Heading>
</Section>
```
覚えておいてほしいのだが、これはあなたが動作させようとしていたマークアップである：
```
// App.js
import Heading from './Heading.js';
import Section from './Section.js';

export default function Page() {
  return (
    <Section level={1}>
      <Heading>Title</Heading>
      <Section level={2}>
        <Heading>Heading</Heading>
        <Heading>Heading</Heading>
        <Heading>Heading</Heading>
        <Section level={3}>
          <Heading>Sub-heading</Heading>
          <Heading>Sub-heading</Heading>
          <Heading>Sub-heading</Heading>
          <Section level={4}>
            <Heading>Sub-sub-heading</Heading>
            <Heading>Sub-sub-heading</Heading>
            <Heading>Sub-sub-heading</Heading>
          </Section>
        </Section>
      </Section>
    </Section>
  );
}
```
```
// Section.js
export default function Section({ children }) {
  return (
    <section className="section">
      {children}
    </section>
  );
}
```
```
// Heading.js
import { useContext } from 'react';
import { LevelContext } from './LevelContext.js';

export default function Heading({ children }) {
  const level = useContext(LevelContext);
  switch (level) {
    case 1:
      return <h1>{children}</h1>;
    case 2:
      return <h2>{children}</h2>;
    case 3:
      return <h3>{children}</h3>;
    case 4:
      return <h4>{children}</h4>;
    case 5:
      return <h5>{children}</h5>;
    case 6:
      return <h6>{children}</h6>;
    default:
      throw Error('Unknown level: ' + level);
  }
}
```
```
// LevelContest.js
import { createContext } from 'react';

export const LevelContext = createContext(1);
```
この例はまだうまくいっていない！すべての見出しのサイズが同じなのは、コンテキストを使用しているにもかかわらず、それをまだ提供していないからです。Reactはコンテキストをどこで取得すればいいのかわからないのです！

コンテキストを指定しないと、Reactは前のステップで指定したデフォルト値を使用します。この例では、createContextの引数に1を指定したので、useContext(LevelContext)は1を返し、すべての見出しを`<h1>`に設定します。各`<Section>`に独自のコンテキストを提供させることで、この問題を解決しましょう。

## ステップ 3: コンテキストの提供
Sectionコンポーネントは現在、子コンポーネントをレンダリングしています：
```
export default function Section({ children }) {
  return (
    <section className="section">
      {children}
    </section>
  );
}
```
それらをコンテキスト・プロバイダでラップして、LevelContext を提供します：
```
import { LevelContext } from './LevelContext.js';

export default function Section({ level, children }) {
  return (
    <section className="section">
      <LevelContext.Provider value={level}>
        {children}
      </LevelContext.Provider>
    </section>
  );
}
```
これはReactにこう伝えます。"この`<Section>`内のコンポーネントがLevelContextを要求したら、このlevelを渡せ"。コンポーネントは、その上のUIツリーで最も近い<LevelContext.Provider>の値を使用します。
```
// App.js
import Heading from './Heading.js';
import Section from './Section.js';

export default function Page() {
  return (
    <Section level={1}>
      <Heading>Title</Heading>
      <Section level={2}>
        <Heading>Heading</Heading>
        <Heading>Heading</Heading>
        <Heading>Heading</Heading>
        <Section level={3}>
          <Heading>Sub-heading</Heading>
          <Heading>Sub-heading</Heading>
          <Heading>Sub-heading</Heading>
          <Section level={4}>
            <Heading>Sub-sub-heading</Heading>
            <Heading>Sub-sub-heading</Heading>
            <Heading>Sub-sub-heading</Heading>
          </Section>
        </Section>
      </Section>
    </Section>
  );
}
```
```
// Section.js
import { LevelContext } from './LevelContext.js';

export default function Section({ level, children }) {
  return (
    <section className="section">
      <LevelContext.Provider value={level}>
        {children}
      </LevelContext.Provider>
    </section>
  );
}
```
```
// Heading.js
import { useContext } from 'react';
import { LevelContext } from './LevelContext.js';

export default function Heading({ children }) {
  const level = useContext(LevelContext);
  switch (level) {
    case 1:
      return <h1>{children}</h1>;
    case 2:
      return <h2>{children}</h2>;
    case 3:
      return <h3>{children}</h3>;
    case 4:
      return <h4>{children}</h4>;
    case 5:
      return <h5>{children}</h5>;
    case 6:
      return <h6>{children}</h6>;
    default:
      throw Error('Unknown level: ' + level);
  }
}
```
```
// LevelContext.js
import { createContext } from 'react';

export const LevelContext = createContext(1);
```
これは元のコードと同じ結果ですが、各 Heading コンポーネントに level プロップを渡す必要はありません！その代わりに、上の最も近いSectionに尋ねることで、その見出しレベルを "把握 "します：

・`<Section>`にlevel propを渡します。

・Sectionはその子を<LevelContext.Provider value={level}>にラップします。

・Heading は、useContext(LevelContext) を使用して、上記の LevelContext の最も近い値を尋ねます。
