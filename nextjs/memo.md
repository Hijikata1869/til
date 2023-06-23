## 6/1
### クライアントコンポーネント

## 6/3
Nextjs12の学習に移行

 ## 6/10
 getStaticProps, getStaticPaths

 ## 6/23
 ### useSWR

 SWRはデータ取得のためのReact Hooksライブラリです。

SWR」という名前は、HTTP RFC 5861で普及したキャッシュ無効化戦略であるstale-while-revalidateに由来する。SWRは、まずキャッシュからデータを返し（stale）、次にリクエストを送り（revalidate）、最後に再び最新のデータを返します。

```
import useSWR from 'swr'

function Profile() {
  const { data, error } = useSWR('/api/user', fetcher)

  if (error) return <div>failed to load</div>
  if (!data) return <div>loading...</div>
  return <div>hello {data.name}!</div>
}
```
この例では、React Hook useSWRはキーとフェッチャー関数を受け取る。キーはリクエストの一意な識別子で、通常はAPIのURLである。フェッチャーはパラメータとしてキーを受け取り、非同期でデータを返す。

useSWRはまた、データとエラーの2つの値を返す。リクエスト（フェッチャー）がまだ終了していない場合、dataは未定義になる。そして、レスポンスを受け取ると、フェッチャーの結果に基づいてdataとerrorを設定し、コンポーネントを再レンダリングする。

フェッチャーはどんな非同期関数でも構わないので、好きなデータ・フェッチ・ライブラリを使ってその部分を処理できることに注意してください。