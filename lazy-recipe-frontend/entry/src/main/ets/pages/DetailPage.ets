import { Recipe } from '../model/Recipe';
import router from '@ohos.router';

@Entry
@Component
export struct DetailPage {
  private recipe: Recipe = {
    id: 0,
    title: '',
    ingredients: [],
    taste: '',
    style: '',
    difficulty: '',
    timeMinutes: 0,
    steps: []
  };

  aboutToAppear() {
    const params = router.getParams();
    if (params) {
      this.recipe = params as Recipe;
    }
  }

  build() {
    Scroll() {
      Column() {
        Text(this.recipe.title)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10 })

        Text(`口味：${this.recipe.taste}｜菜系：${this.recipe.style}`)
        Text(`难度：${this.recipe.difficulty}｜时间：${this.recipe.timeMinutes}`)
          .margin({ bottom: 10 })

        Text('所需食材：').fontSize(18).margin({ top: 10, bottom: 4 })
        Text(this.recipe.ingredients.join('、'))

        Text('步骤：').fontSize(18).margin({ top: 20, bottom: 4 })
        ForEach(this.recipe.steps, (step: string, index: number) => {
          Text(`步骤 ${index + 1}：${step}`)
            .margin({ bottom: 6 })
        })

        Button("返回")
          .margin({ top: 30 })
          .onClick(() => {
            router.back();
          })
      }
      .padding(20)
    }
  }
}
