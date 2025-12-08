import http from '@ohos.net.http';
import { RecommendRequest } from '../model/RecommendRequest';

export class HttpClient {
  static baseUrl: string = "http://10.135.15.156:8080/api";

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

  static async post<T>(path: string, body: RecommendRequest): Promise<T> {
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
