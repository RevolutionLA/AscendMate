import { ConfigurationConstant } from '@kit.AbilityKit';

@Component
export struct BrandLogo {
  @Prop logoWidth: number = 200;
  @StorageProp('isDark') isDark: boolean = false;

  build() {
    Image(this.isDark ? $rawfile('brand/ascend-logo-dark.svg') : $rawfile('brand/ascend-logo.svg'))
      .width(this.logoWidth)
      .height(this.logoWidth * 32 / 84)
      .draggable(false)
      .objectFit(ImageFit.Contain)
  }
}
