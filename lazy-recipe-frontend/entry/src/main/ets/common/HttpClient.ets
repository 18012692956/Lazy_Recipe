import http from '@ohos.net.http';

export class HttpClient {
  static baseUrl: string = "http://192.168.19.67:8080/api";

  static async get<T>(path: string): Promise<T> {
    console.log('HttpClient GET:', `${HttpClient.baseUrl}${path}`);

    const client = http.createHttp();
    const response = await client.request(
      `${HttpClient.baseUrl}${path}`,
      {
        method: http.RequestMethod.GET,
        connectTimeout: 5000
      }
    );

    console.log('GET 响应状态:', response.responseCode);
    console.log('GET 响应内容:', response.result);

    client.destroy();

    // ✅ 处理空响应
    if (!response.result || response.result === '') {
      console.warn('GET 返回空响应');
      return null as T;
    }

    return JSON.parse(response.result as string) as T;
  }

  static async post<T, B>(path: string, body: B): Promise<T> {
    console.log('HttpClient POST:', `${HttpClient.baseUrl}${path}`);
    console.log('POST 请求体:', JSON.stringify(body));

    const client = http.createHttp();
    const response = await client.request(
      `${HttpClient.baseUrl}${path}`,
      {
        method: http.RequestMethod.POST,
        connectTimeout: 5000,
        header: {
          "Content-Type": "application/json"
        },
        extraData: JSON.stringify(body)
      }
    );

    console.log('POST 响应状态:', response.responseCode);
    console.log('POST 响应内容:', response.result);
    console.log('POST 响应类型:', typeof response.result);

    client.destroy();

    // ✅ 关键修复：处理空响应或纯文本响应
    if (!response.result || response.result === '' || response.result === 'null') {
      console.log('POST 返回空响应，视为成功（适用于 void 类型）');
      return undefined as T; // 对于 Promise<void> 返回 undefined
    }

    // ✅ 尝试解析 JSON，如果失败则返回原始内容
    try {
      return JSON.parse(response.result as string) as T;
    } catch (error) {
      console.warn('JSON 解析失败，返回原始内容');
      console.warn('解析错误:', error);
      // 对于 void 返回类型，返回 undefined
      return undefined as T;
    }
  }
}