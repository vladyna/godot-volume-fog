using Godot;
using Godot.Collections;

namespace VolumetricFog
{
    public partial class VolumetricFogController : Node3D
    {
        #region Exposed Dependencies
        [Export] private ShaderMaterial _fogMaterial;
        [Export] private int _maxLights = 8;
        [Export] private Array<OmniLight3D> _lights;
        [Export] private float _maxFogDensity = 5f;
        [Export] private float _fogSpread = 0f;
        [Export] private FogVolume _fogVolume;
        #endregion

        #region Private Variables
        private Vector3[] _lightArray;
        private float[] _lightRadiuses;
        private Vector3[] _lightColors;
        #endregion

        #region Godot's Methods
        public override void _Ready()
        {
            if (_fogMaterial == null)
                return;
            Initialize();
        }
        public override void _Process(double delta)
        {
            UpdateFog();
        }
        #endregion

        #region Public Methods
        public void AddOmniLight(OmniLight3D light)
        {
            if (_lights.Count < _maxLights)
            {
                _lights.Add(light);
            }
            else
            {
                GD.PushWarning("Cannot add more lights maximum amount reached");
            }
        }
        public void RemoveOmniLight(OmniLight3D light)
        {
            if (_lights.Contains(light))
            {
                _lights.Remove(light);
            }
        }
        #endregion

        #region Private Methods 
        private void Initialize()
        {
            _lightArray = new Vector3[_maxLights];
            _lightRadiuses = new float[_maxLights];
            _lightColors = new Vector3[_maxLights];

            _fogMaterial.SetShaderParameter("spread_progress", 0);

            UpdateFogShaderLights();
        }

        private void UpdateFog()
        {
            if (_fogMaterial == null)
                return;

            UpdateFogShaderLights();
            _fogMaterial.SetShaderParameter("spread_progress", _fogSpread);
        }

        private void UpdateFogShaderLights()
        {

            for (int i = 0; i < _lights.Count; i++)
            {
                if (i < _lights.Count)
                {
                    var light = _lights[i];
                    var color = light.LightColor;
                    _lightArray[i] = light.GlobalPosition;
                    _lightRadiuses[i] = light.OmniRange * 4;
                    _lightColors[i] = new Vector3(color.R, color.G, color.B);
                }

            }

            _fogMaterial.SetShaderParameter("light_positions", _lightArray);
            _fogMaterial.SetShaderParameter("light_count", _lights.Count);
            _fogMaterial.SetShaderParameter("light_radiuses", _lightRadiuses);
            _fogMaterial.SetShaderParameter("light_colors", _lightColors);
            _fogMaterial.SetShaderParameter("fog_size", GetVolumeLongsetSide());
        }

        private float GetVolumeLongsetSide()
        {
            var size = _fogVolume.Size;
            return size.X > size.Y ? size.X > size.Z ? size.X : size.Z : size.Y > size.Z ? size.Y : size.Z;
        }
        #endregion

    }
}