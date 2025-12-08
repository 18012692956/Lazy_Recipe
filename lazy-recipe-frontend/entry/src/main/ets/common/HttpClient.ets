import http from '@ohos.net.http';
import { RecommendRequest } from '../model/Request';

export class HttpClient {
  static baseUrl: string = "http://192.168.19.62:8080/api";

  static async get<T>(path: string): Promise<T> {
    const client = http.createHttp();
    const response = await client.request(
      `${HttpClient.baseUrl}${path}`,
      {
        method: http.RequestMethod.GET,
        connectTimeout: 5000
      }
    );
    client.destroy();

    return JSON.parse(response.result as string) as T;
  }

  static async post<T, B>(path: string, body: B): Promise<T> {
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
    client.destroy();

    return JSON.parse(response.result as string) as T;
  }
}
