import { ApiService } from '../common/ApiService';
import { Recipe } from '../model/Recipe';
import { RecommendRequest } from '../model/RecommendRequest';
import router from '@ohos.router';

@Entry
@Component
export struct RecommendPage {

  @State recipes: Recipe[] = [];

  private navParams: RecommendRequest = {
    ingredients: [],
    taste: "",
    style: ""
  };

  aboutToAppear() {
    // HarmonyOS NEXT 标准方法：获取路由参数
    const params = router.getParams();

    if (params) {
      this.navParams = params as RecommendRequest;
    }

    this.loadRecipes();
  }

  private async loadRecipes() {
    this.recipes = await ApiService.recommend(
      this.navParams.ingredients,
      this.navParams.taste,
      this.navParams.style
    );
  }

  build() {
    Column() {
      if (this.recipes.length === 0) {
        Text("正在加载推荐菜谱…")
          .fontSize(20)
          .margin({ top: 20 });
      } else {
        List() {
          ForEach(this.recipes, (r: Recipe) => {
            ListItem() {
              Column() {
                Text(r.title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)

                Text(`难度：${r.difficulty}｜耗时：${r.timeMinutes}`)
                  .fontSize(16)
                  .margin({ top: 4 })
              }
              .padding(12)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/DetailPage',
                  params: r  // 直接传递整个 recipe 对象，或 r.id
                });
              })
            }
          }, (r: Recipe) => r.id.toString())
        }
      }

      Button("返回")
        .margin({ bottom: 10 })
        .onClick(() => {
          router.back();
        })
    }
    .padding(20)
  }

}
